# frozen_string_literal: true

module Support
  module Inspecting
    module Types
      extend Support::Typespace

      # An object that has an `id` attribute.
      #
      # @return [Dry::Types::Type]
      HasId = Interface(:id)

      # An object that has a model name
      #
      # @return [Dry::Types::Type]
      HasModelName = Interface(:model_name)

      # An object that has a `name` attribute.
      #
      # @return [Dry::Types::Type]
      HasName = Interface(:name)

      # An object that has a `title` attribute.
      #
      # @return [Dry::Types::Type]
      HasTitle = Interface(:title)

      # A model instance
      #
      # @return [Dry::Types::Type]
      ModelInstance = ::Support::Models::Types::Model

      # A sum type that matches a model instance or something with a model name.
      #
      # @see HasModelName
      # @see HasId
      # @return [Dry::Types::Type]
      ModelLike = ModelInstance | HasModelName
    end
  end
end
