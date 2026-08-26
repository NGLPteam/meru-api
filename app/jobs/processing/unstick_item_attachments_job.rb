# frozen_string_literal: true

module Processing
  # @see Item
  class UnstickItemAttachmentsJob < AbstractUnstickAttachmentsJob
    model_klass Item
  end
end
