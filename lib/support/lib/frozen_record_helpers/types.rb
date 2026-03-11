# frozen_string_literal: true

module Support
  module FrozenRecordHelpers
    module Types
      extend ::Support::Typespace

      CalculatedAttributes = Hash.map(Coercible::String, Interface(:call))

      DefaultAttributes = Hash.map(Coercible::String, Any)

      DefaultSQLValues = Array.of(Symbol)

      Schema = Nominal(Dry::Schema::Processor)
    end
  end
end
