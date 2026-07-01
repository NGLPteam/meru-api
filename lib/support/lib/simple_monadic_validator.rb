# frozen_string_literal: true

module Support
  # @abstract
  #
  # A base class for implementing validators
  class SimpleMonadicValidator
    extend ActiveModel::Callbacks
    extend Dry::Core::ClassAttributes

    include Dry::Monads[:list, :validated, :result]

    defines :check_map, type: Support::Types::MethodMap

    define_model_callbacks :check

    check_map({})

    # @return [Dry::Monads::Result]
    def call
      run_checks!

      compile_checks
    end

    private

    # @return [void]
    def run_checks!
      run_callbacks :check do
        @checks = run_checks
      end
    end

    def run_checks
      self.class.check_map.transform_values do |check_name|
        public_send check_name
      end
    end

    def compile_checks
      List::Validated.coerce(@checks.values).traverse.to_result
    end

    class << self
      # @param [Symbol] name
      # @yieldreturn [Dry::Monads::Validated]
      def check!(name, &)
        method_name = :"check_#{name}!"

        # simplecov:disable
        raise "check already exists: #{name}" if check_map.key?(name)
        # simplecov:enable

        define_method(method_name, &)

        check_map check_map.merge(name => method_name)
      end
    end
  end
end
