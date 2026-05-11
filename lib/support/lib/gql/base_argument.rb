# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    class BaseArgument < ::GraphQL::Schema::Argument
      # @abstract
      def initialize(*args, attribute: true, transient: false, replace_null_with_default: nil, **kwargs, &block)
        @attribute = attribute
        @transient = transient

        replace_null_with_default = !kwargs[:default_value].nil? if replace_null_with_default.nil?

        super(*args, replace_null_with_default:, **kwargs, &block)
      end

      def attribute? = @attribute.present?

      # @return [<String>]
      def attribute_names(names: [], parent: nil) = argument_paths_for_if(&:attribute?)

      # @param [<String>] names
      # @param [String, nil] parent
      # @yield [arg]
      # @yieldparam [Types::BaseArgument] arg
      # @yieldreturn [Boolean]
      # @return [<String>]
      def argument_paths_for_if(names: [], parent: nil, &block)
        argument_name = [parent, keyword || name].compact.join(?.)

        names << argument_name if yield(self)

        nested_arguments.each_with_object(names) do |arg, n|
          names += arg.argument_paths_for_if(names: n, parent: argument_name, &block) if yield(arg)
        end
      end

      # @api private
      # @return [<Types::BaseArgument>]
      def nested_arguments
        if type.respond_to?(:arguments)
          type.arguments.values
        elsif type.respond_to?(:of_type) && type.of_type.respond_to?(:arguments)
          type.of_type.arguments.values
        else
          []
        end
      end

      # @return [<Symbol>]
      def transient_arguments(names: [], parent: nil)
        argument_paths_for_if(&:transient?).map do |arg|
          arg.split(?.).map { _1.to_s.underscore }.join(?.).to_sym
        end
      end

      def transient? = @transient
    end
  end
end
