# frozen_string_literal: true

module Support
  module GQL
    # A consolidated interface for a model that implements a number of other interfaces.
    module CommonModelType
      include Support::GQL::BaseInterface

      implements ::GraphQL::Types::Relay::Node

      implements ::Support::GQL::CommonPermissionsType
      implements ::Support::GQL::HasDefaultTimestampsType
      implements ::Support::GQL::SluggableType
    end
  end
end
