# frozen_string_literal: true

module Support
  module MessageMaps
    class Configuration
      include Support::Typing
      include Dry::Initializer[undefined: false].define -> do
        param :map_name, Types::MethodName

        option :dsl_base, Types::MethodName

        option :single_dsl_method, Types::MethodName, default: -> { :"#{dsl_base.to_s.singularize}!" }
        option :plural_dsl_method, Types::MethodName, default: -> { :"#{dsl_base.to_s.pluralize}!" }
        option :realize_method, Types::MethodName, default: -> { :"realize_#{map_name}" }
      end

      # @return [Symbol]
      attr_reader :config_name

      # @return [Support::MessageMaps::InstanceImplementation]
      attr_reader :instance_implementation

      # @return [Symbol]
      attr_reader :ivar

      # @return [Support::MessageMaps::KlassImplementation]
      attr_reader :klass_implementation

      def initialize(...)
        super

        @config_name = :"#{map_name}_config"

        @ivar = :"@#{map_name}"

        @klass_implementation = KlassImplementation.new(self)
        @instance_implementation = @klass_implementation.instance_implementation
      end
    end
  end
end
