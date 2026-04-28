# frozen_string_literal: true

module Filtering
  module Scopes
    class Items < Filtering::FilterScope[Item]
      boolean_scope! :include_drafts, truthy_scope: :all, falsey_scope: :sans_drafts, default_value: false, replace_null: true do |arg|
        arg.description <<~TEXT
        Whether to include items that are in draft state (i.e. items that are associated with a submission).
        TEXT

        timestamps!
      end
    end
  end
end
