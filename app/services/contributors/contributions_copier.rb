# frozen_string_literal: true

module Contributors
  # Copy all {ItemContribution} and {CollectionContribution} records
  # from a source {Contributor} to its merge target (if available).
  #
  # @see Contributors::CopyContributions
  class ContributionsCopier < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :source_contributor, Types::Contributor
    end

    standard_execution!

    COPIED = { items: 0, collections: 0 }.freeze

    # @return [{ :items, :collections => Integer }]
    attr_reader :copied

    # @return [<Hash>]
    attr_reader :collection_tuples

    # @return [<Hash>]
    attr_reader :item_tuples

    # @return [Contributor, nil]
    attr_reader :target_contributor

    delegate :id, to: :target_contributor, prefix: :contributor, allow_nil: true

    # @return [Dry::Monads::Success({ :items, :collections => Integer })]
    def call
      run_callbacks :execute do
        yield prepare!

        yield copy!
      end

      Success copied
    end

    wrapped_hook! def prepare
      @target_contributor = source_contributor.merge_target

      @copied = COPIED.dup

      return Failure[:not_merging] unless source_contributor.merging?

      return Failure[:no_merge_target] unless target_contributor.present?

      @item_tuples = source_contributor.item_contributions.map(&:to_copy_tuple)

      @collection_tuples = source_contributor.collection_contributions.map(&:to_copy_tuple)

      super
    end

    wrapped_hook! def copy
      @copied[:items] = upsert_tuples!(ItemContribution, item_tuples)

      @copied[:collections] = upsert_tuples!(CollectionContribution, collection_tuples)

      yield target_contributor.recount_contributions

      super
    end

    private

    # @param [Class(Contribution)] klass
    # @param [<Hash>] tuples
    # @return [Integer] number of contributions copied
    def upsert_tuples!(klass, tuples)
      # simplecov:disable
      return 0 if tuples.empty?
      # simplecov:enable

      unique_by = klass.contributable_unique_by

      full_tuples = tuples.map { _1.merge(contributor_id:) }

      result = klass.upsert_all(full_tuples, unique_by:, returning: :id)

      result.count
    end
  end
end
