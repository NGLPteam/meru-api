# frozen_string_literal: true

module Resolvers
  # Definitions for abstract ordering.
  #
  # These are more or less consistent across all models,
  # and if a model needs to implement it in a different way,
  # it can be overridden in the resolver itself.
  module AbstractOrdering
    extend ActiveSupport::Concern

    class << self
      def append_features(base)
        base.extend BuildsOrderPair if base.kind_of?(Module)

        super
      end
    end

    included do
      defines :order_enum_klass, type: ::Support::DryGQL::Types::EnumClass.optional
    end

    module BuildsOrderPair
      # @return [void]
      def order_pair!(base, **options)
        builder = OrderPairBuilder.new(self, base, **options)

        builder.call
      end
    end

    # @api private
    class OrderPairBuilder
      include Dry::Initializer[undefined: false].define -> do
        param :klass, Support::GlobalTypes.Interface(:class_eval)

        param :base, ::Support::GlobalTypes::Coercible::Symbol

        option :ascending_suffix, ::Support::GlobalTypes::Coercible::Symbol, default: proc { :"#{base}_ascending" }
        option :descending_suffix, ::Support::GlobalTypes::Coercible::Symbol, default: proc { :"#{base}_descending" }
        option :column, ::Support::GlobalTypes::Coercible::Symbol, default: proc { base }
      end

      def call
        klass.class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def apply_order_with_#{ascending_suffix}(scope)
          scope.lazily_order(#{column.inspect}, :asc)
        end

        def apply_order_with_#{descending_suffix}(scope)
          scope.lazily_order(#{column.inspect}, :desc)
        end
        RUBY
      end
    end

    extend BuildsOrderPair

    # Order by a model-specific hierarchy.
    #
    # @note The model _must_ implement `in_default_order.
    # @param [ActiveRecord::Relation#in_default_order] scope
    # @return [ActiveRecord::Relation#in_default_order]
    def apply_order_with_default(scope)
      scope.in_default_order
    end

    # Order by an inverted model-specific hierarchy.
    #
    # @note The model _must_ implement `in_inverse_order`.
    # @param [ActiveRecord::Relation#in_inverse_order] scope
    # @return [ActiveRecord::Relation#in_inverse_order]
    def apply_order_with_inverse(scope)
      scope.in_inverse_order
    end

    # Order by `created_at ASC`.
    #
    # @param [ActiveRecord::Relation] scope
    # @return [ActiveRecord::Relation]
    def apply_order_with_recent(scope)
      scope.in_recent_order
    end

    # Order by `created_at DESC`.
    #
    # @param [ActiveRecord::Relation] scope
    # @return [ActiveRecord::Relation]
    def apply_order_with_oldest(scope)
      scope.in_oldest_order
    end

    # Order by `updated_at ASC`.
    #
    # @param [ActiveRecord::Relation] scope
    # @return [ActiveRecord::Relation]
    def apply_order_with_recent_updates(scope)
      scope.most_recently_updated
    end

    # Order by `updated_at DESC`.
    #
    # @param [ActiveRecord::Relation] scope
    # @return [ActiveRecord::Relation]
    def apply_order_with_oldest_updates(scope)
      scope.least_recently_updated
    end

    order_pair! :title

    module ClassMethods
      include BuildsOrderPair

      # @param [Class<Types::BaseEnum>] enum_klass
      # @return [void]
      def orders_with!(enum_klass, default: nil, replace_null_with_default: true)
        introspector = Support::DryGQL::OrderEnumIntrospector.new(enum_klass)

        order_enum_klass enum_klass

        default ||= introspector.default_value

        defines :order_enum_default, type: enum_klass.dry_type

        order_enum_default default

        options = {
          type: enum_klass,
          default:,
          argument_options: {
            replace_null_with_default:,
          },
        }

        option(:order, **options)
      end
    end
  end
end
