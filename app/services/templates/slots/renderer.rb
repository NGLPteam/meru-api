# frozen_string_literal: true

module Templates
  module Slots
    class Renderer < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :raw_template, Types::Coercible::String

        option :assigns, Types::Assigns, default: proc { {} }

        option :force, Types::Bool, default: proc { false }

        option :hide_when_empty, Types::Bool, default: proc { false }

        option :kind, Types::SlotKind, default: proc { "block" }
      end

      standard_execution!

      # @return [Boolean]
      attr_reader :compiled

      alias compiled? compiled

      # @return [String]
      attr_reader :content

      # @return [Boolean]
      attr_reader :empty

      alias empty? empty

      # @return [Boolean]
      attr_reader :hides_template

      # @return [<String>, nil]
      attr_reader :liquid_errors

      # @return [Templates::Slots::Instances::Abstract]
      attr_reader :slot

      # @return [Class(Templates::Slots::Instances::Abstract)]
      attr_reader :slot_klass

      # @return [Liquid::Template]
      attr_reader :template

      # @return [Boolean]
      attr_reader :rendered

      alias rendered? rendered

      def call
        run_callbacks :execute do
          yield prepare!

          yield compile_template!

          yield render!

          yield build_slot!
        end

        Success slot
      end

      wrapped_hook! def prepare
        @slot_klass = Templates::Slots::Abstract.instance_klass_for(kind)

        @empty = raw_template.blank?

        @compiled = @hides_template = @rendered = false

        @content = @template = nil

        @liquid_errors = []

        super
      end

      wrapped_hook! def compile_template
        if raw_template.blank?
          @compiled = true

          return super
        end

        result = call_operation("templates.slots.compile", raw_template, force:, kind:)

        Dry::Matcher::ResultMatcher.call result do |m|
          m.success do |template|
            @compiled = true

            @template = template
          end

          m.failure(:syntax_error) do |_, error|
            @liquid_errors << Templates::Slots::Error.from(error)
          end

          m.failure do
            # simplecov:disable
            raise "Something went critically wrong with compilation process"
            # simplecov:enable
          end
        end

        super
      end

      wrapped_hook! def render
        return super unless compiled?

        if empty?
          @rendered = false

          @content = ""

          return super
        end

        raw = template.render(assigns, strict_filters: true, strict_variables: true)

        template.errors.each do |error|
          @liquid_errors << Templates::Slots::Error.from(error)
        end

        @rendered = liquid_errors.blank?

        @content = yield call_operation("templates.slots.sanitize", raw, kind:) if rendered?

        @hides_template = content.blank? if hide_when_empty

        super
      end

      wrapped_hook! def build_slot
        @liquid_errors = liquid_errors.compact_blank.presence

        @slot = slot_klass.new(compiled:, content:, empty: content.blank?, hides_template:, liquid_errors:, rendered:)

        super
      end
    end
  end
end
