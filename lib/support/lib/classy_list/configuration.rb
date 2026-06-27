# frozen_string_literal: true

module Support
  module ClassyList
    class Configuration
      include Support::Typing
      include Dry::Initializer[undefined: false].define -> do
        param :list_name, Types::MethodName

        option :item_type, Support::Types::DryType, default: -> { Types::Any }

        option :list_type, Support::Types::DryType, default: -> { Types::Array.of(item_type) }

        option :dsl_base, Types::MethodName, default: -> { list_name }

        option :single_dsl_method, Types::MethodName, default: -> { :"#{dsl_base.to_s.singularize}!" }
        option :plural_dsl_method, Types::MethodName, default: -> { :"#{dsl_base.to_s.pluralize}!" }
        option :realize_mode, Types::RealizeMode, default: -> { :none }
        option :realize_method, Types::MethodName, default: -> { :"realize_#{list_name}" }
      end

      # @return [Symbol]
      attr_reader :config_name

      # @return [Support::ClassyList::InstanceImplementation]
      attr_reader :instance_implementation

      # @return [Symbol]
      attr_reader :ivar

      # @return [Support::ClassyList::KlassImplementation]
      attr_reader :klass_implementation

      def initialize(...)
        super

        @config_name = :"#{list_name}_config"

        @ivar = :"@#{list_name}"

        @klass_implementation = KlassImplementation.new(self)
        @instance_implementation = @klass_implementation.instance_implementation
      end

      # @return [Support::ClassyList::List]
      def build_list = ::Support::ClassyList::List.new(config: self)

      def realize? = realize_mode != :none
    end
  end
end
