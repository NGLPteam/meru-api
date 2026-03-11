# frozen_string_literal: true

module Support
  module Authorization
    module Types
      extend ::Support::Typespace

      # An action
      ActionName = Coercible::Symbol.constrained(format: /\A[a-z]\w+[a-z]\z/)

      ActionNames = Coercible::Array.of(ActionName)

      Callable = Interface(:call)

      # A list of values that can satisfy an {ActionName}
      ConditionList = Array

      Conditions = ConditionList.constrained(min_size: 1)

      ConditionLogic = Coercible::Symbol.default(:all).enum(:all, :any, :not, :nor)

      ConditionPositiveLogic = Coercible::Symbol.default(:all).enum(:all, :any)

      ConditionName = Coercible::Symbol.constrained(format: /\A[a-z]\w+[a-z]\z/, excluded_from: ConditionLogic)

      ConditionNames = Coercible::Array.of(ConditionName)

      ConditionResolver = Callable.constructor do |input|
        case input
        when Symbol then input.to_proc
        else
          input
        end
      end

      Dependencies = Coercible::Array

      Predicate = Coercible::Symbol.constrained(format: /\A[a-z]\w+[a-z]\?\z/)

      Predicates = Coercible::Array.of(Predicate)

      SingleCondition = Array.of(ConditionName).constrained(size: 1)
    end
  end
end
