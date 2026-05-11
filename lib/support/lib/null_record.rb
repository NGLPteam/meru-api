# frozen_string_literal: true

module Support
  # @abstract
  class NullRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
