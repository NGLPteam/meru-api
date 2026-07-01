# frozen_string_literal: true

module LiquidExt
  module Tags
    # @api private
    class ParsedArgs
      include Dry::Core::Constants
      include Dry::Initializer[undefined: false].define -> do
        param :tag_name, Types::String
        param :markup, Types::Coercible::String
        param :tokens, Types.Instance(Liquid::ParseContext)

        option :arg_names, Types::ArgNames, default: proc { EMPTY_ARRAY }
      end

      # Split on commas, but respect quotation marks and
      # allow them to contain commas (just in case).
      MARKUP_PATTERN = /
        (?:
          (?:"[^"]+?")
          |
          (?:'[^']+?')
          |
          (?:[^,]+\s*)
        )
      /x

      # Match `foo: "bar"` pattern.
      KWARG_PATTERN = /\A\s*(?<name>[^:[:space:]]+):\s*(?<expression>.+)\z/

      delegate :parse_expression, to: :tokens

      def initialize(...)
        super

        set_up!

        parse_markup!
      end

      # @param [Symbol, Integer] index_or_name
      # @return [LiquidExt::Tags::ParsedArg, nil]
      def at(index_or_name, allow_blank: false)
        case index_or_name
        in Integer
          if allow_blank
            arg_values[index_or_name]
          else
            arg_values.fetch(index_or_name)
          end
        in Symbol
          if allow_blank
            kwargs.fetch index_or_name do
              args.fetch(index_or_name, nil)
            end
          else
            kwargs.fetch index_or_name do
              args.fetch(index_or_name)
            end
          end
        end
      end

      alias [] at

      # @see LiquidExt::Tags::ParsedArg#evaluate_asset
      # @param [Symbol, Integer] index_or_name
      # @return [Asset, nil]
      def asset(index_or_name, context, allow_blank: false)
        at(index_or_name, allow_blank:)&.evaluate_asset(context)
      end

      # @see LiquidExt::Tags::ParsedArg#evaluate_entity
      # @param [Symbol, Integer] index_or_name
      # @return [HierarchicalEntity, nil]
      def entity(index_or_name, context, allow_blank: false)
        at(index_or_name, allow_blank:)&.evaluate_entity(context)
      end

      # @see LiquidExt::Tags::ParsedArg#evaluate
      # @param [Symbol, Integer] index_or_name
      # @return [Object, nil]
      def evaluate(index_or_name, context, allow_blank: false)
        at(index_or_name, allow_blank:)&.evaluate(context)
      end

      def evaluate_many(*names, context:, allow_blank: true)
        names.flatten.index_with do |name|
          evaluate(name, context, allow_blank:)
        end
      end

      # @param [Symbol, Integer] index_or_name
      def has?(index_or_name)
        case index_or_name
        in Integer
          arg_values.fetch(index, false)
        in Symbol
          kwargs.fetch index_or_name do
            args.fetch(index_or_name, false)
          end
        end.present?
      end

      # @return [{ Symbol => LiquidExt::Tags::ParsedArg }]
      attr_reader :args

      # @return [<LiquidExt::Tags::ParsedArg>]
      attr_reader :arg_values

      # @return [{ Symbol => LiquidExt::Tags::ParsedArg }]
      attr_reader :kwargs

      private

      def parse_markup!
        return if markup.blank?

        markup.to_s.scan(MARKUP_PATTERN).map(&:strip).each do |raw_expression|
          parse_argument! raw_expression
        end
      end

      def parse_argument!(raw_expression)
        case raw_expression
        when KWARG_PATTERN
          parse_kwarg!(Regexp.last_match[:name], Regexp.last_match[:expression])
        else
          parse_positional_arg!(raw_expression)
        end
      end

      # @return [void]
      def parse_kwarg!(name, expression)
        value = parse_expression(expression)

        arg = LiquidExt::Tags::ParsedArg.new(value:, expression:, name:, kwarg: true)

        @kwargs[name.to_sym] = arg
      end

      # @return [void]
      def parse_positional_arg!(expression)
        index = @arg_values.size

        value = parse_expression(expression)

        name = arg_names[index]

        arg = LiquidExt::Tags::ParsedArg.new(value:, expression:, name:, index:)

        @arg_values << arg

        # simplecov:disable
        @args[name] = arg if name
        # simplecov:enable
      end

      # @return [void]
      def set_up!
        @arg_values = []

        @args = {}

        @kwargs = {}
      end
    end
  end
end
