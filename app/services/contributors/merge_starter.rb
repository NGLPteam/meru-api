# frozen_string_literal: true

module Contributors
  # @see Contributors::MergeTo
  class MergeStarter < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :source, Types::Contributor

      param :target, Types::Contributor

      option :enqueue_merge_job, Types::Bool, default: proc { false }
    end

    standard_execution!

    delegate :id, to: :target, prefix: :merge_target

    around_execute :acquire_transaction!
    around_execute :acquire_source_lock!
    around_execute :acquire_target_lock!

    # @return [Dry::Monads::Success(Contributor, Contributor)]
    # @return [Dry::Monads::Failure(:same_contributor)]
    # @return [Dry::Monads::Failure(:source_merging)]
    # @return [Dry::Monads::Failure(:target_merging)]
    def call
      run_callbacks :execute do
        yield check!

        yield mark_for_merge!
      end

      Contributors::MergeJob.perform_later(source, target) if enqueue_merge_job

      Success [source, target]
    end

    wrapped_hook! def check
      yield source.check_merge_to(target)

      super
    end

    wrapped_hook! def mark_for_merge
      return super if source.merging_to?(target)

      source.update! merge_target: target, merge_source_status: :merging

      super
    end

    private

    # @return [void]
    def acquire_transaction!
      ActiveRecord::Base.transaction do
        ApplicationRecord.with_advisory_lock!("contributors.merge", timeout_seconds: 30, transaction: true, disable_query_cache: true) do
          yield
        end
      end
    end

    # @return [void]
    def acquire_source_lock!
      source.with_lock do
        yield
      end
    end

    # @return [void]
    def acquire_target_lock!
      target.with_lock do
        yield
      end
    end
  end
end
