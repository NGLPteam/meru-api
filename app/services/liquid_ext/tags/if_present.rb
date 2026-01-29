# frozen_string_literal: true

module LiquidExt
  module Tags
    # We'd like the ability to check for the presence of an entire chain call in Liquid
    # without having to enumerate. In addition, we'd like Rails `present?` logic instead
    # of the Rubyish truthiness checks. This tag accomplishes that.
    class IfPresent < LiquidExt::Tags::AbstractIfBlock
      if_tag! "ifpresent"

      # @param [Liquid::Condition, Liquid::ElseCondition] block
      # @param [Object] result
      # @return [Boolean]
      def evaluate_if_branch?(block, result)
        case result
        when ::LiquidExt::Behavior::BlankAndPresent
          result.is_present
        else
          result.present? || super
        end
      end
    end
  end
end
