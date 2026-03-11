# frozen_string_literal: true

module Searching
  # Types module for searching subsystem.
  module Types
    extend ::Support::Typespace

    # @api private
    OPERATOR_NAMES = %w[
      equals
      matches
      in_any
      date_gte
      date_lte
      numeric_gte
      numeric_lte
    ].freeze

    EntityOrigin = Entities::Types::Entity

    GlobalOrigin = Value(:global)

    JoinEncoder = Interface(:call)

    MaxDepth = Searching::Types::Integer.constrained(gt: 0)

    OrderingOrigin = ModelInstance("Ordering")

    SchemaOrigin = ModelInstance("SchemaVersion")

    OperatorName = Coercible::String.enum(*OPERATOR_NAMES)

    OriginModel = GlobalOrigin | EntityOrigin | OrderingOrigin | SchemaOrigin

    OriginType = Symbol.enum(:entity, :global, :ordering, :schema).constructor do |value|
      case value
      when EntityOrigin then :entity
      when OrderingOrigin then :ordering
      when SchemaOrigin then :schema
      else
        value
      end
    end

    # A type that automatically builds an origin.
    #
    # @see Searching::Origin
    Origin = Instance(::Searching::Origin).constructor do |value|
      case value
      when OriginModel, nil then ::Searching::Origin.new(value)
      else
        value
      end
    end
  end
end
