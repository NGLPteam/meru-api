# frozen_string_literal: true

module Harvesting
  module Extraction
    # A context object that generates assigns and similar data for a {HarvestRecord}.
    class RenderContext
      include Dry::Effects::Handler.Reader(:additional_assigns)
      include Dry::Effects.Reader(:additional_assigns, default: Dry::Core::Constants::EMPTY_HASH)
      include Dry::Initializer[undefined: false].define -> do
        param :harvest_record, ::Harvesting::Types::Record

        option :metadata_context, Types.Instance(::Harvesting::Metadata::Context), default: proc { harvest_record.build_metadata_context }
        option :extraction_context, Types.Instance(::Harvesting::Extraction::Context), default: proc { harvest_record.build_extraction_context }
      end

      delegate :mapping, to: :extraction_context

      # @return [{ String => Object }]
      attr_reader :assigns

      # @return [Harvesting::Extraction::Contributions::Config]
      attr_reader :contributions

      # @api private
      # @return [Liquid::Environment]
      attr_reader :environment

      def initialize(...)
        super

        @environment = MeruAPI::Container["harvesting.extraction.build_environment"].().value!

        compile_assigns!

        configure_contributions!
      end

      # @return [{ String => Object }]
      def current_assigns
        assigns.reverse_merge(additional_assigns)
      end

      # @note This makes use of an extension we've made to Liquid in order to
      #   evaluate expressions at runtime.
      # @param [String] markup
      # @return [Object]
      def lookup(markup)
        build_empty_template.lookup_expression(markup)
      end

      # @return [<Harvesting::Entities::Struct>]
      def render_entity_structs
        mapping.entity_mapping.render_structs_for self
      end

      # @param [#to_s] key
      # @param [Object] value
      # @return [void]
      def with_additional_assign(key, value)
        new_assigns = additional_assigns.merge(key.to_s => value).freeze

        with_additional_assigns new_assigns do
          yield
        end
      end

      # @param [{ String => Object }] pairs
      # @return [void]
      def with_additional_assigns!(pairs = {})
        new_assigns = additional_assigns.merge(pairs.stringify_keys).freeze

        with_additional_assigns new_assigns do
          yield
        end
      end

      # @param [String] element
      # @param [String] expression
      def with_enumerated_assignment(element:, expression:)
        arr = Array(lookup(expression))

        arr.each_with_index do |value, index|
          element_idx = "#{element}_idx"
          element_pos = "#{element}_pos"

          position = index + 1

          enumerated_assigns = {
            element => value,
            element_idx => index,
            element_pos => position,
          }

          with_additional_assigns! enumerated_assigns do
            yield
          end
        end
      end

      private

      def build_empty_template
        Liquid::Template.parse("", environment:, line_numbers: false).tap do |tpl|
          tpl.assigns.merge!(current_assigns)
        end
      end

      # @return [void]
      def compile_assigns!
        @assigns = metadata_context.assigns.with_indifferent_access

        compile_shared_assigns!

        @assigns = @assigns.stringify_keys.freeze
      end

      # @return [void]
      def compile_shared_assigns!
        # :nocov:
        return if mapping.nil?
        # :nocov:

        mapping.each_shared_assignment do |assignment|
          @assigns[assignment.name] ||= assignment.value_for(self)
        end
      end

      # @return [void]
      def configure_contributions!
        # :nocov:
        return if mapping.nil?
        # :nocov:

        @contributions = mapping.to_contributions_config
      end
    end
  end
end
