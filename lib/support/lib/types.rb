# frozen_string_literal: true

module Support
  module Types
    extend ::Support::Typespace

    # @api private
    module RelationHelper
      def of(klass)
        type.constrained(relation_for: klass)
      end
    end

    BigDecimal = Instance(::BigDecimal).constructor do |value|
      case value
      when ::BigDecimal then value
      when Float then BigDecimal(value, 4)
      when Integer, Coercible::Float, Coercible::Integer then BigDecimal(value)
      else
        value
      end
    end

    DefinitionName = Coercible::Symbol

    DryType = Nominal(::Dry::Types::Type).constrained(type: ::Dry::Types::Type)

    MethodMap = Hash.map(Symbol, Symbol)

    IncludedPort = Coercible::Integer.constrained(excluded_from: [80, 443])

    ModelClass = Class.constrained(model_class: true)

    ModelInstanceNamed = ->(specific_model) { Instance(ActiveRecord::Base).constrained(specific_model:) }

    Module = Nominal(::Module).constrained(type: ::Module, case: ->(o) { !o.kind_of?(::Class) })

    MutationVerb = Coercible::Symbol.enum(:create, :update, :destroy, :unknown).fallback(:unknown)

    ParamsReorderer = Instance(Support::Params::Reorderer)

    Relation = Nominal(::ActiveRecord::Relation).constrained(relation: true)

    Relation.extend(RelationHelper)

    SafeBoolean = Types::Params::Bool.fallback { false }

    SymbolicMap = Hash.map(Coercible::Symbol, Coercible::Symbol)
  end
end
