# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {SubmissionComment} with {::Types::SubmissionCommentOrderType}.
  module OrderedAsSubmissionComment
    extend ActiveSupport::Concern

    include ::Resolvers::AbstractOrdering

    included do
      orders_with! ::Types::SubmissionCommentOrderType, default: "DEFAULT"
    end
  end
end
