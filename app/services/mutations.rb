# frozen_string_literal: true

# Mutations are GraphQL operations that modify data.
module Mutations
  extend Dry::Core::ClassAttributes

  class << self
    # Set up a block that lets logic within it know that
    # a mutation is currently active: this affects certain
    # lifecycle methods (e.g. template rendering).
    #
    # @see ModelMutationSupport
    # @see Mutations::Current
    # @return [void]
    def with_active!(&)
      Mutations::Current.with_active!(active: true, &)
    end
  end
end
