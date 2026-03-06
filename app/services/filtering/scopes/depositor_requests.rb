# frozen_string_literal: true

module Filtering
  module Scopes
    # The filtering scope implementation for {DepositorRequest}.
    class DepositorRequests < ::Filtering::FilterScope[::DepositorRequest]
      simple_state_filter! :depositor_request_states

      timestamps!
    end
  end
end
