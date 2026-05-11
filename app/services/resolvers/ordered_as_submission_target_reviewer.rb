# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {SubmissionTargetReviewer} with {::Types::SubmissionTargetReviewerOrderType}.
  module OrderedAsSubmissionTargetReviewer
    extend ActiveSupport::Concern

    include ::Resolvers::AbstractOrdering

    included do
      orders_with! ::Types::SubmissionTargetReviewerOrderType, default: "DEFAULT"
    end
  end
end
