# frozen_string_literal: true

class TunerMetric < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes
end
