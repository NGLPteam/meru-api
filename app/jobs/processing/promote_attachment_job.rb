# frozen_string_literal: true

module Processing
  class PromoteAttachmentJob < ApplicationJob
    queue_as :processing

    discard_on ActiveRecord::RecordNotFound

    discard_on Shrine::AttachmentChanged

    # @param [String] attacher_class
    # @param [String] record_class
    # @param [String] record_id
    # @param [String] name
    # @param [Hash, String] file
    # @return [void]
    def perform(record, name, file_data)
      record.promote_attachment!(name, file_data:)
    end
  end
end
