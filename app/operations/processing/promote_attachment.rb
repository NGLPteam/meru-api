# frozen_string_literal: true

module Processing
  # @see Processing::AttachmentPromoter
  class PromoteAttachment < Support::SimpleServiceOperation
    service_klass Processing::AttachmentPromoter
  end
end
