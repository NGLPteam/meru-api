# frozen_string_literal: true

module Support
  module Requests
    # Current connection path for GraphQL requests.
    class CurrentConnection < ActiveSupport::CurrentAttributes
      attribute :current_path
      attribute :info, default: -> { Requests::ConnectionInfo.unknown }
    end
  end
end
