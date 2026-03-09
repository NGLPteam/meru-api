# frozen_string_literal: true

# @see GenericAccessiblePolicy
module GenericAccessible
  extend ActiveSupport::Concern

  def policy_class = self.class.policy_class

  module ClassMethods
    def policy_class = GenericAccessiblePolicy
  end
end
