# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {Permalink} with {::Types::PermalinkOrderType}.
  module OrderedAsPermalink
    extend ActiveSupport::Concern

    include ::Resolvers::AbstractOrdering

    included do
      orders_with! ::Types::PermalinkOrderType, default: "DEFAULT"
    end
  end
end
