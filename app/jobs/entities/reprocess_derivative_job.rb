# frozen_string_literal: true

module Entities
  # Reprocess a specific attachment derivative for an individual {HierarchicalEntity}
  class ReprocessDerivativeJob < ApplicationJob
    queue_as :processing

    discard_on NoMethodError

    retry_on Redis::TimeoutError, wait: :polynomially_longer

    unique_job! by: :all_args

    around_perform do |job, block|
      Schemas::Orderings.with_disabled_refresh do
        block.call
      end
    end

    # @param [HierarchicalEntity] entity
    # @param [Symbol] name
    # @return [void]
    def perform(entity, name)
      attacher = entity.public_send(:"#{name}_attacher")

      return unless attacher.stored?

      old_derivatives = attacher.derivatives

      attacher.set_derivatives({})
      attacher.create_derivatives

      begin
        attacher.atomic_persist
        attacher.delete_derivatives(old_derivatives)
      rescue Shrine::AttachmentChanged, ActiveRecord::RecordNotFound
        # simplecov:disable
        attacher.delete_derivatives # remove orphans
        # simplecov:enable
      end
    end
  end
end
