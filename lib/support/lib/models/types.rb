# frozen_string_literal: true

module Support
  module Models
    # Types specific to working with {ApplicationRecord models}.
    module Types
      extend ::Support::Typespace

      # A Global ID instance or URI.
      GlobalID = Constructor(GlobalID, GlobalID.method(:parse)).constrained(global_id: true)

      # An array of GlobalID URIs or instances.
      GlobalIDList = Array.of(GlobalID)

      # An instance of a model
      #
      # @see ApplicationRecord
      Model = Any.constrained(model: true)

      # An array of model instances.
      #
      # @see Model
      ModelList = Array.of(Model)

      # A single model class.
      ModelClass = Any.constrained(model_class: true)

      # An array of model classes
      #
      # @see ModelClass
      ModelClassList = Array.of(ModelClass)
    end
  end
end
