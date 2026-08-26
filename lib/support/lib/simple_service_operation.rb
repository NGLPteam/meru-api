# frozen_string_literal: true

module Support
  # @abstract
  #
  # A class for defining an operation that takes its args
  # and provides it to a specific service that implements `#call`.
  class SimpleServiceOperation
    extend Dry::Core::ClassAttributes

    defines :service_klass, type: Support::Types::Class

    service_klass Support::NullService

    # @return [Dry::Monads::Result]
    def call(...)
      self.class.service_klass.new(...).__send__(:call)
    end
  end
end
