# frozen_string_literal: true

module Support
  module MessageMaps
    # @api private
    class Map
      # @param [{ Symbol => #call, Symbol }] mapping A mapping of method names to messages
      #   that can be used to generate reified mappings.
      def initialize(mapping = Dry::Core::Constants::EMPTY_HASH)
        @mapping = Types::Mapping[mapping]

        @mapping.freeze
      end

      # @api private
      # @param [Support::MessageMaps::Map] original
      # @return [void]
      def initialize_copy(original)
        super

        @mapping = original.mapping.dup.freeze
      end

      # @param [<Symbol>] method_names A list of method names to map to themselves.
      # @param [Hash{Symbol => #call, Symbol }] additional_mapping
      # @return [Support::MessageMaps::Map] A new map instance with the merged results
      def merge(*method_names, **additional_mapping)
        simple_mapping = method_names.reduce({}) do |acc, method_name|
          case method_name
          in Types::Mapping then acc.merge(method_name)
          in Types::MethodName then acc.merge(method_name => method_name)
          else
            # simplecov:disable
            raise ArgumentError, "Invalid method name: #{method_name.inspect}"
            # simplecov:enable
          end
        end

        new_mapping = simple_mapping.merge(additional_mapping)

        merged = mapping.merge(new_mapping)

        Map.new(merged)
      end

      # @param [Object] object The object to realize the mapping for.
      # @return [{ Symbol => Object }]
      def realize(object)
        mapping.transform_values do |message|
          case message
          in Types::Callable
            message.call(object)
          else
            object.__send__(message)
          end
        end
      end

      protected

      # @return [Hash{ Symbol => #call, Symbol }]
      attr_reader :mapping
    end
  end
end
