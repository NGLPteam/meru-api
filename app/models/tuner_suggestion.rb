# frozen_string_literal: true

class TunerSuggestion < ApplicationRecord
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include TimestampScopes
end
