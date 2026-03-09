# frozen_string_literal: true

# @api private
module Ahoy
  class Event < ApplicationRecord
    include GenericInaccessible
    include Ahoy::QueryMethods

    self.table_name = "ahoy_events"

    belongs_to :visit, inverse_of: :events
    belongs_to :user, optional: true
    belongs_to :entity, optional: true, polymorphic: true
    belongs_to :subject, optional: true, polymorphic: true

    pg_enum! :context, as: "analytics_context"
  end
end
