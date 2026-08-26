# frozen_string_literal: true

module Processing
  # @see Collection
  class UnstickCollectionAttachmentsJob < AbstractUnstickAttachmentsJob
    model_klass Collection
  end
end
