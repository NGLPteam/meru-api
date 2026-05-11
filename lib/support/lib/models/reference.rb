# frozen_string_literal: true

module Support
  module Models
    # A lazily-evaluated reference to an application-space model,
    # which can be used to defer loading until runtime.
    class Reference
      extend ActiveModel::Callbacks
      extend Dry::Initializer

      include Dry::Core::Equalizer.new(:name)
      include Support::Realizable

      param :name, ::Support::Models::Types::Name

      option :_model_name, ::Support::Models::Types::ActiveModelName, as: :model_name, default: -> do
        ::ActiveModel::Name.new(nil, nil, name)
      end

      # @!attribute [r] klass
      # @return [Class(ApplicationRecord)]
      def klass
        @klass or realized!
      end

      private

      # @return [void]
      def realization
        @klass = name.constantize
      end
    end
  end
end
