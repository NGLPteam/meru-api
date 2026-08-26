# frozen_string_literal: true

module Processing
  # @abstract
  class AbstractUnstickAttachmentsJob < ApplicationJob
    extend Dry::Core::ClassAttributes

    include JobIteration::Iteration

    defines :model_klass, type: Support::Types::ModelClass

    model_klass ApplicationRecord

    queue_as :maintenance

    # @param [String] cursor
    # @return [void]
    def build_enumerator(cursor:)
      enumerator_builder.active_record_on_records(
        model_klass.with_any_stuck_shrine_attachments,
        cursor:
      )
    end

    # @param [ApplicationRecord] model
    # @return [void]
    def each_iteration(model)
      model.unstick_shrine_attachments!
    end

    private

    def model_klass = self.class.model_klass
  end
end
