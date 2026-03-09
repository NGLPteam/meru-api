# frozen_string_literal: true

# @see GenericInaccessiblePolicy
module GenericInaccessible
  extend ActiveSupport::Concern

  def policy_class = self.class.policy_class

  module ClassMethods
    def policy_class = GenericInaccessiblePolicy
  end
end
