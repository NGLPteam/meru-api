# frozen_string_literal: true

class TunerMetric < ApplicationRecord
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include TimestampScopes
end
