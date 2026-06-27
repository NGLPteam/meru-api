# frozen_string_literal: true

module Access
  # @see Access::PolymorphicGrant
  class PolymorphicGranter < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :subject, Access::Types::Subject

      option :manager_on, Access::Types::Accessibles, default: proc { Dry::Core::Constants::EMPTY_ARRAY }
      option :editor_on, Access::Types::Accessibles, default: proc { Dry::Core::Constants::EMPTY_ARRAY }
      option :reviewer_on, Access::Types::Accessibles, default: proc { Dry::Core::Constants::EMPTY_ARRAY }
      option :depositor_on, Access::Types::Accessibles, default: proc { Dry::Core::Constants::EMPTY_ARRAY }
      option :author_on, Access::Types::Accessibles, default: proc { Dry::Core::Constants::EMPTY_ARRAY }
      option :reader_on, Access::Types::Accessibles, default: proc { Dry::Core::Constants::EMPTY_ARRAY }
    end

    standard_execution!

    # @return [<Access::RoleApplicator>]
    attr_reader :role_applicators

    # @return [Dry::Monads::Result]
    def call
      run_callbacks :execute do
        yield prepare!

        yield apply_each!
      end

      subject.reload

      Success()
    end

    wrapped_hook! def prepare
      @role_applicators = build_role_applicators

      super
    end

    wrapped_hook! def apply_each
      role_applicators.each do |applicator|
        applicator.apply!(subject)
      end

      super
    end

    private

    # @return [<Access::RoleApplicator>]
    def build_role_applicators
      Role::POLYMORPHIC_GRANTABLE_MAP.map do |role, accessibles_key|
        accessibles = __send__(accessibles_key)

        Access::RoleApplicator.new(role:, accessibles:)
      end
    end
  end
end
