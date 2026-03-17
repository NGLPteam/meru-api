# frozen_string_literal: true

module Schemas
  module Properties
    # A context object that is used to produce a {Schemas::Properties::Context value context}.
    #
    # @see Schemas::Properties::BaseDefinition#write_values_within!
    class WriteContext
      include Dry::Monads[:result]

      include Dry::Initializer.define -> do
        param :entity, Schemas::Types::SchemaInstance
        param :version, Schemas::Types.Instance(SchemaVersion)
        param :input_values, Schemas::Types::ValueHash
      end

      # This is called by the applicator when all the properties have been processed
      # and are ready to be written to the entity.
      #
      # @return [Schemas::Properties::Context]
      def finalize = Schemas::Properties::Context.new(**value_context)

      def within_group!(path)
        @current_values = fetch_group(path)
        @current_output = output_group(path)
        @prefix = path

        yield
      ensure
        @current_values = input_values
        @current_output = output_values
        @prefix = nil
      end

      # @param [String] path
      # @return [Dry::Monads::Result]
      def copy_value!(path)
        write_value! path, value_for(path) if has_value?(path)

        Success nil
      end

      def has_value?(path) = current_values.key? path

      def value_for(path) = current_values[path]

      def write_value!(path, value) = current_output[path] = value

      # @param [String] path
      # @return [void]
      def write_collected_references!(path)
        full_path = full_path_for path

        referents = Array(value_for(path))

        value_context[:collected_references][full_path] = referents

        Success nil
      end

      # @param [String] path
      # @return [void]
      def write_full_text!(path)
        full_path = full_path_for path

        attributes = value_for(path)

        value_context[:full_texts][full_path] = attributes

        Success nil
      end

      # @param [String] path
      # @return [void]
      def write_scalar_reference!(path)
        full_path = full_path_for path

        referent = value_for path

        value_context[:scalar_references][full_path] = referent

        Success nil
      end

      private

      def current_values
        @current_values ||= input_values
      end

      def current_output
        @current_output ||= output_values
      end

      def fetch_group(path) = @input_values.fetch(path, {})

      def full_path_for(path)
        @prefix.present? ? [@prefix, path].join(?.) : path
      end

      def output_group(path)
        output_values[path] ||= {}
      end

      def output_values
        @output_values ||= value_context[:values]
      end

      def value_context
        @value_context ||= { values: {}, collected_references: {}, full_texts: {}, scalar_references: {} }
      end
    end
  end
end
