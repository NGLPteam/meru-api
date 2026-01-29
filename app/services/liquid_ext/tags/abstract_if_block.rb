# frozen_string_literal: true

module LiquidExt
  module Tags
    # @abstract An abstract Liquid tag for conditional blocks.
    class AbstractIfBlock < Liquid::Block
      extend Dry::Core::ClassAttributes

      DEFAULT_ELSE_TAG_NAMES = %w[
        $never_match$
        $always_fail$
      ].freeze

      # @!attribute [r] if_tag_name
      #   @!scope class
      #   The name of the "if" tag for this conditional tag.
      #   @return [String]
      # @!attribute [r] elsif_tag_name
      #   @!scope class
      #   The name of the "elsif" tag for this conditional tag.
      #   @return [String]
      defines :if_tag_name, :elsif_tag_name, type: LiquidExt::Types::String

      # @!attribute [r] else_tag_names
      #   @!scope class
      #   The names of the "else" tags for this conditional tag.
      #   @return [LiquidExt::Types::TagNames]
      defines :else_tag_names, type: LiquidExt::Types::ElseTagNames

      if_tag_name "$if_never_match$"

      elsif_tag_name "$els_never_match$"

      else_tag_names DEFAULT_ELSE_TAG_NAMES.freeze

      Syntax = /(#{Liquid::QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{Liquid::QuotedFragment})?/o

      ExpressionsAndOperators = /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{Liquid::QuotedFragment}|\S+)\s*)+)/o

      BOOLEAN_OPERATORS = %w[and or].freeze

      # The blocks / conditions for this tag.
      # @return [<Liquid::Condition, Liquid::ElseCondition>]
      attr_reader :blocks

      # @param [String] tag_name
      # @param [String] markup
      # @param [Liquid::ParseContext] options
      def initialize(tag_name, markup, options)
        super
        @blocks = []
        push_block("if", markup)
      end

      # @api private
      def nodelist
        # :nocov:
        @blocks.map(&:attachment)
        # :nocov:
      end

      # @api private
      def parse(tokens)
        while parse_body(@blocks.last.attachment, tokens); end

        @blocks.reverse_each do |block|
          # :nocov:
          block.attachment.remove_blank_strings if blank?
          # :nocov:
          block.attachment.freeze
        end
      end

      # @api private
      # @note A hook provided by Liquid::Block
      def unknown_tag(tag, markup, tokens)
        if else_tag?(tag)
          push_block(tag, markup)
        else
          # :nocov:
          super
          # :nocov:
        end
      end

      # @api private
      def render_to_output_buffer(context, output)
        @blocks.each do |block|
          result = Liquid::Utils.to_liquid_value(
            block.evaluate(context),
          )
        rescue Liquid::UndefinedVariable, Liquid::UndefinedDropMethod
          # We allow undefined variables and drop method calls to occur here, regardless of strict variables.
          next
        else
          if evaluate_if_branch?(block, result)
            return block.attachment.render_to_output_buffer(context, output)
          end
        end

        # :nocov:
        output
        # :nocov:
      end

      # @param [String, Symbol] name
      def else_tag?(name) = name.in?(else_tag_names)

      # @!attribute [r] else_tag_names
      #   The names of the "else" tags for this conditional tag.
      #   @return [<String>]
      def else_tag_names = self.class.else_tag_names

      private

      # @abstract Override in subclasses to customize truthiness evaluation.
      # @note Defer to `super` for else logic.
      # @param [Liquid::Condition, Liquid::ElseCondition] block
      # @param [Object] result
      def evaluate_if_branch?(block, result)
        block.kind_of?(Liquid::ElseCondition) && result.present?
      end

      def push_block(tag, markup)
        block =
          if tag == "else"
            Liquid::ElseCondition.new
          else
            parse_with_selected_parser(markup)
          end

        @blocks.push(block)

        block.attach(new_body)
      end

      def parse_expression(markup)
        Liquid::Condition.parse_expression(parse_context, markup)
      end

      def lax_parse(markup)
        expressions = markup.scan(ExpressionsAndOperators)

        # :nocov:
        raise Liquid::SyntaxError, options[:locale].t("errors.syntax.if") unless expressions.pop =~ Syntax
        # :nocov:

        condition = Liquid::Condition.new(parse_expression(Regexp.last_match(1)), Regexp.last_match(2), parse_expression(Regexp.last_match(3)))

        until expressions.empty?
          operator = expressions.pop.to_s.strip

          # :nocov:
          raise Liquid::SyntaxError, options[:locale].t("errors.syntax.if") unless expressions.pop.to_s =~ Syntax
          # :nocov:

          new_condition = Liquid::Condition.new(parse_expression(Regexp.last_match(1)), Regexp.last_match(2), parse_expression(Regexp.last_match(3)))

          # :nocov:
          raise Liquid::SyntaxError, options[:locale].t("errors.syntax.if") unless BOOLEAN_OPERATORS.include?(operator)
          # :nocov:

          new_condition.send(operator, condition)

          condition = new_condition
        end

        condition
      end

      def strict_parse(markup)
        p = @parse_context.new_parser(markup)

        condition = parse_binary_comparisons(p)

        p.consume(:end_of_string)

        condition
      end

      def parse_binary_comparisons(p)
        condition = parse_comparison(p)

        first_condition = condition

        while (op = p.id?("and") || p.id?("or"))
          child_condition = parse_comparison(p)
          condition.send(op, child_condition)
          condition = child_condition
        end

        first_condition
      end

      def parse_comparison(p)
        a = parse_expression(p.expression)

        if (op = p.consume?(:comparison))
          # :nocov:
          b = parse_expression(p.expression)
          Liquid::Condition.new(a, op, b)
          # :nocov:
        else
          Liquid::Condition.new(a)
        end
      end

      class << self
        # Define the tag names for this conditional block.
        #
        # @return [void]
        def if_tag!(name, elsif_tag: "els#{name}")
          if_tag_name name.freeze

          elsif_tag_name elsif_tag.freeze

          else_tag_names [elsif_tag_name, "else"].freeze
        end
      end

      # @api private
      # Required for introspection in Liquid
      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        # @return [<Liquid::Condition, Liquid::ElseCondition>]
        def children
          # :nocov:
          @node.blocks
          # :nocov:
        end
      end
    end
  end
end
