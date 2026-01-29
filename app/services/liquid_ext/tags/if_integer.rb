# frozen_string_literal: true

module LiquidExt
  module Tags
    # Liquid lacks the ability to test if a value is a whole number (integer).
    # This tag implements that functionality, along with Rails' `present?` logic.
    class IfInteger < LiquidExt::Tags::AbstractIfBlock
      INTEGER_MATCH = /\A-?\d+\z/

      if_tag! "ifinteger"

      private

      # @param [Liquid::Condition, Liquid::ElseCondition] block
      # @param [Object] result
      def evaluate_if_branch?(block, result)
        case result
        when Integer, INTEGER_MATCH then true
        else
          super
        end
      end
    end
  end
end
