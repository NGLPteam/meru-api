# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {SubmissionReview} with {::Types::SubmissionReviewOrderType}.
  module OrderedAsSubmissionReview
    extend ActiveSupport::Concern

    include ::Resolvers::AbstractOrdering

    included do
      orders_with! ::Types::SubmissionReviewOrderType, default: "DEFAULT"
    end
  end
end
