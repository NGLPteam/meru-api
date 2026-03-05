# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {SubmissionTarget} with {::Types::SubmissionTargetOrderType}.
  module OrderedAsSubmissionTarget
    extend ActiveSupport::Concern

    include ::Resolvers::AbstractOrdering

    included do
      orders_with! ::Types::SubmissionTargetOrderType, default: "DEFAULT"
    end
  end
end
