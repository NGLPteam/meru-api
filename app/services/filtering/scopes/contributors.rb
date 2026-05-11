# frozen_string_literal: true

module Filtering
  module Scopes
    class Contributors < Filtering::FilterScope[Contributor]
      has_name_search!

      boolean_scope! :unclaimed do |arg|
        arg.description <<~TEXT
        Whether to include only contributors that have not been claimed by a user.
        TEXT
      end

      timestamps!
    end
  end
end
