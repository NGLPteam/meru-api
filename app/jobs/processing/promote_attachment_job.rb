# frozen_string_literal: true

module Processing
  class PromoteAttachmentJob < ApplicationJob
    queue_as :processing

    discard_on ActiveRecord::RecordNotFound

    # @param [ApplicationRecord] record
    # @param [String] name
    # @param [Hash, String] file_data
    # @return [void]
    def perform(record, name, file_data)
      record.promote_attachment!(name, file_data:)
    end
  end
end
