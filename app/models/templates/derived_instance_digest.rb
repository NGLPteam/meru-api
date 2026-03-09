# frozen_string_literal: true

module Templates
  # @api private
  class DerivedInstanceDigest < ApplicationRecord
    include GenericAccessible
    include TimestampScopes
    include View

    self.primary_key = :template_instance_id
  end
end
