# frozen_string_literal: true

module DefinesMonadicOperation
  VALID_TO_NIL = proc {}

  def monadic_matcher!(method_name, with: Dry::Matcher::ResultMatcher)
    include Dry::Matcher.for(method_name, with:)

    monadic_operation!(method_name)
  end

  # @return [void]
  def monadic_operation!(method_name)
    class_eval <<~RUBY, __FILE__, __LINE__ + 1
      def #{method_name}!(...)
        #{method_name}(...).value!.then do |result|
          Dry::Monads::Unit == result ? nil : result
        end
      end
    RUBY
  end

  # @param [Symbol] method_name
  # @return [void]
  def monadic_validator!(method_name)
    class_eval <<~RUBY, __FILE__, __LINE__ + 1
      def #{method_name}!(...)
        enumerate_reasons = ->(reasons) do
          reasons.to_a.each do |reason|
            yield reason if block_given?
          end
        end

        #{method_name}(...).either(
          VALID_TO_NIL,
          enumerate_reasons
        )
      end
    RUBY
  end
end
