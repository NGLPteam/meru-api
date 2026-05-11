# frozen_string_literal: true

module Contributors
  # @see Contributors::CheckMerge
  class MergeChecker < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :source, Types::Contributor

      param :target, Types::Contributor
    end

    standard_execution!

    # @return [:available, :existing, :unknown]
    attr_reader :pair_status

    # @return [Dry::Monads::Success(:available)]
    # @return [Dry::Monads::Success(:existing)]
    # @return [Dry::Monads::Failure(:same_contributor)]
    # @return [Dry::Monads::Failure(:source_merging)]
    # @return [Dry::Monads::Failure(:target_merging)]
    def call
      run_callbacks :execute do
        yield check!
      end

      Success pair_status
    end

    wrapped_hook! def check
      @pair_status = source.merging_to?(target) ? :existing : :unknown

      return super if @pair_status == :existing

      return Failure[:same_contributor] if source == target

      return Failure[:source_merging] if source.merge_started?

      return Failure[:target_merging] if target.merge_started?

      @pair_status = :available

      super
    end
  end
end
