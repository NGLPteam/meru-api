# frozen_string_literal: true

module Processing
  # @see Community
  class UnstickCommunityAttachmentsJob < AbstractUnstickAttachmentsJob
    model_klass Community
  end
end
