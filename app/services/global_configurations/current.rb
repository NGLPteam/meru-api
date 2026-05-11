# frozen_string_literal: true

module GlobalConfigurations
  # Current request attributes for GraphQL requests.
  class Current < ActiveSupport::CurrentAttributes
    attribute :record, default: proc { GlobalConfiguration.fetch }
  end
end
