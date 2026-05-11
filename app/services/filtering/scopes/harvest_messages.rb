# frozen_string_literal: true

module Filtering
  module Scopes
    class HarvestMessages < Filtering::FilterScope[::HarvestMessage]
      simple_scope_filter! :severity, :harvest_message_level,
        scope_name: :severity,
        default_value: "info",
        replace_null: true
    end
  end
end
