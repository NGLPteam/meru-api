# frozen_string_literal: true

module Support
  module Models
    # Types specific to working with {ApplicationRecord models}.
    module Types
      extend ::Support::Typespace

      # An instance of `ActiveModel::Name`.
      #
      # @return [Dry::Types::Type]
      ActiveModelName = Instance(::ActiveModel::Name)

      # A Global ID instance or URI.
      #
      # @return [Dry::Types::Type]
      GlobalID = Constructor(GlobalID, GlobalID.method(:parse)).constrained(global_id: true)

      # An array of GlobalID URIs or instances.
      #
      # @return [Dry::Types::Type]
      GlobalIDList = Array.of(GlobalID)

      # An instance of a model
      #
      # @see ApplicationRecord
      #
      # @return [Dry::Types::Type]
      Model = Any.constrained(model: true)

      # An array of model instances.
      #
      # @see Model
      #
      # @return [Dry::Types::Type]
      ModelList = Array.of(Model)

      # A single model class.
      #
      # @return [Dry::Types::Type]
      ModelClass = Any.constrained(model_class: true)

      # An array of model classes
      #
      # @see ModelClass
      #
      # @return [Dry::Types::Type]
      ModelClassList = Array.of(ModelClass)

      # A string representing the name of a model, which can be used for lazy loading.
      #
      # @return [Dry::Types::Type]
      Name = Coercible::String.constrained(format: /\A(?:::)?[A-Z]\S+\z/)

      # An array of model names.
      #
      # @return [Dry::Types::Type]
      Names = Array.of(Name)
    end
  end
end
