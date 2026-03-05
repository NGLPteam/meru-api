# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {Submission} with {::Types::SubmissionOrderType}.
  module OrderedAsSubmission
    extend ActiveSupport::Concern

    include ::Resolvers::AbstractOrdering

    included do
      orders_with! ::Types::SubmissionOrderType, default: "DEFAULT"
    end
  end
end
