# frozen_string_literal: true

class TunerSuggestion < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes
end
