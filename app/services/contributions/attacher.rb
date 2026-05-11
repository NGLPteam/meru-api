# frozen_string_literal: true

module Contributions
  # This will upsert a {Contribution} for the combination of its inputs.
  #
  # @see Contributions::Attach
  class Attacher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :contributor, Contributions::Types::Contributor, as: :provided_contributor

      param :contributable, Contributions::Types::Contributable

      option :role, Contributions::Types::Role.optional, as: :provided_role, optional: true

      option :inner_position, Contributions::Types::Integer.optional, optional: true

      option :outer_position, Contributions::Types::Integer.optional, optional: true
    end

    standard_execution!

    # @return [::Contributor]
    attr_reader :contributor

    # @return [::Contribution]
    attr_reader :contribution

    # @return [ControlledVocabularyItem]
    attr_reader :role

    # @return [Hash]
    attr_reader :tuple

    # @return [<Symbol>]
    attr_reader :unique_by

    delegate :contributable_foreign_key, :contributions_klass, to: :contributable
    delegate :contributable_key, :contributables_key, to: :contributions_klass

    delegate :id, to: :contributable, prefix: true
    delegate :id, to: :contributor, prefix: true
    delegate :id, to: :role, prefix: true

    # @return [Dry::Monads::Success(Contribution)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield upsert!

        yield recount!

        yield manage_attributions!
      end

      Success contribution
    end

    wrapped_hook! def prepare
      @contributor = provided_contributor.to_attach

      @role = provided_role || call_operation!("contribution_roles.fetch_default", contributable:)

      @tuple = build_tuple

      @unique_by = [:contributor_id, contributable_foreign_key, :role_id]

      super
    end

    wrapped_hook! def upsert
      result = contributions_klass.upsert(tuple, unique_by:, returning: :id)

      contribution_id = result.pick("id")

      @contribution = contributions_klass.find(contribution_id)

      super
    end

    wrapped_hook! def recount
      operation = "contributors.count_#{contributables_key}"

      yield call_operation(operation, contributor)

      super
    end

    wrapped_hook! def manage_attributions
      operation = "attributions.#{contributables_key}.manage"

      options = {
        contributable_key => contributable
      }

      yield call_operation(operation, **options)

      super
    end

    private

    def build_tuple
      { contributor_id:, role_id:, inner_position:, outer_position:, }.compact.tap do |h|
        h[contributable_foreign_key] = contributable_id
      end
    end
  end
end
