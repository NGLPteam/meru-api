# frozen_string_literal: true

module Access
  # A simple applicator pattern that takes a role, multiple accessible targets,
  # and can {#apply} that role to any number of subjects by its callers.
  #
  # @see Access::Grant
  # @see Access::PolymorphicGrant
  # @see Access::PolymorphicGranter
  class RoleApplicator
    extend DefinesMonadicOperation
    extend Dry::Core::Cache

    include Access::Checking
    include Dry::Monads[:result]
    include Enumerable
    include Support::CallsCommonOperation

    include Dry::Initializer[undefined: false].define -> do
      option :role, Access::Types::RoleInput, as: :role_input

      option :accessibles, Access::Types::Accessibles, default: proc { Dry::Core::Constants::EMPTY_ARRAY }
    end

    delegate :empty?, to: :accessibles

    # The mode to use for role assignment.
    #
    # `:reviewer` roles require a little extra handling.
    #
    # @see #reviewer?
    # @see #simple?
    # @return [:simple, :reviewer]
    attr_reader :mode

    # @return [Role]
    attr_reader :role

    delegate :identified_as_reviewer?, to: :role

    def initialize(...)
      super

      @role = derive_role
      @mode = identified_as_reviewer? ? :reviewer : :simple
    end

    # Creating a reviewer is a little different and requires creating
    # a {SubmissionTargetReviewer} join record instead. It will handle
    # the {Role} assignment.
    #
    # @see #mode
    def reviewer? = mode == :reviewer

    # For most roles, we can just rely on {Access::Grant} to handle everything.
    #
    # @see #mode
    def simple? = mode == :simple

    def each
      # simplecov:disable
      return enum_for(:each) unless block_given?
      # simplecov:enable

      accessibles.each do |accessible|
        yield accessible
      end
    end

    def each_entity
      # simplecov:disable
      return enum_for(:each_entity) unless block_given?
      # simplecov:enable

      each do |accessible|
        entity = require_entity!(accessible)

        yield entity
      end
    end

    # @raise [Access::Error] if any of the role applications failed
    # @param [AccessGrantSubject] subject
    # @return [Dry::Monads::Success(Integer)]
    monadic_operation! def apply(subject)
      return Success(0) if empty?

      if reviewer?
        apply_reviewers(subject)
      else
        apply_simple(subject)
      end
    end

    private

    # @raise [Access::Error] if any of the role applications failed
    # @param [AccessGrantSubject] subject
    # @return [Dry::Monads::Success(Integer)]
    def apply_reviewers(subject)
      user = require_user!(subject)

      each_entity do |entity|
        assign_reviewer!(user, entity)
      end

      Success(accessibles.size)
    end

    # @param [AccessGrantSubject] subject
    # @return [Dry::Monads::Success(Integer)]
    def apply_simple(subject)
      each do |accessible|
        assign_simple!(accessible, subject)
      end

      Success(accessibles.size)
    end

    # @param [User] user
    # @param [Submittable] entity
    # @return [Dry::Monads::Success(void)]
    monadic_operation! def assign_reviewer(user, entity)
      submission_target = entity.fetch_submission_target!

      SubmissionTargetReviewer.where(submission_target:, user:).first_or_create!

      Success()
    end

    # @param [Accessible] on
    # @param [AccessGrantSubject] to
    # @return [Dry::Monads::Success(void)]
    monadic_operation! def assign_simple(on, to)
      call_operation("access.grant", role, on:, to:)
    end

    # @return [Role]
    def derive_role
      case role_input
      in Types::RoleIdentifier => identifier
        fetch_role(identifier)
      else
        role_input
      end
    end

    # We can rely upon a fairly static cache of {Role} records
    # here, since system roles are not going to be changing much
    # at all in runtime.
    #
    # @param [Symbol] identifier
    # @return [Role]
    def fetch_role(identifier)
      fetch_or_store(identifier) do
        Role.fetch(identifier)
      end
    end
  end
end
