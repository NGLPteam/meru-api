# frozen_string_literal: true

module Contributors
  # A background job that will merge two {Contributor}s into each other.
  class MergeJob < ApplicationJob
    include ActiveJob::Continuable

    queue_as :default

    discard_on Contributors::MergeInvalid

    # @return [Contributor]
    attr_reader :source

    # @return [Contributor]
    attr_reader :target

    # @param [Contributor] source
    # @param [Contributor] target
    # @return [void]
    def perform(source, target)
      verify_merge_lock!(source, target)

      step :copy_contributions

      step :redirect_harvesting

      step :mark_merge_complete

      step :destroy_source
    end

    private

    # @param [Contributor] source
    # @param [Contributor] target
    # @return [void]
    def verify_merge_lock!(source, target)
      merge_lock = source.merge_to(target)

      merge_lock.or do
        raise Contributors::MergeInvalid, "Failed to acquire merge lock for #{source.id} -> #{target.id}"
      end.value!

      @source = source
      @target = target
    end

    # @return [void]
    def check_result!(result)
      result.or do
        raise Contributors::MergeFailed, "Merge failed: #{result.failure.inspect}"
      end.value!
    end

    # @return [void]
    def copy_contributions
      check_result!(source.copy_contributions)
    end

    def redirect_harvesting
      source.redirect_harvesting_to!(target)
    end

    def mark_merge_complete
      source.update!(merge_source_status: :merged)
    end

    def destroy_source
      source.destroy!
    end
  end
end
