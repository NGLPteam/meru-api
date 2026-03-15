# frozen_string_literal: true

module Roles
  module Grid
    extend ActiveSupport::Concern

    include Roles::ComposesGrids

    included do
      permission_names Dry::Core::Constants::EMPTY_ARRAY
    end

    INHERITED = Dry::Types["class"].constrained(lt: self)

    # @param [#to_s] scope
    # @return [<Permission::Grant>]
    def permissions
      base = { scope: scope.presence }.compact

      own_permissions = self.class.permission_names.map do |name|
        attrs = base.merge(name:, allowed: public_send(name))

        Permissions::Grant.new attrs
      end

      own_permissions + super
    end

    module ClassMethods
      # @param [Boolean, { Symbol => Boolean }] initial_value
      # @return [{ Symbol => Boolean }]
      def build_params_from(initial_value)
        build_permission_params_from(initial_value).merge(super)
      end

      # @param [<Symbol>] names
      # @param [Boolean] default
      # @param [{ Symbol => Boolean }] names_with_defaults
      # @return [void]
      def permission(*names, default: false, **names_with_defaults)
        combined = names.flatten.map(&:to_sym).uniq.index_with { default }.merge(names_with_defaults)

        combined.each do |name, default_value|
          next if name.present? && permission_names.present? && name.in?(permission_names)

          attribute name, :boolean, default: default_value

          new_permission_names = [*permission_names, name].uniq.freeze

          permission_names new_permission_names
        end

        recalculate_available_actions!
      end

      # @api private
      # @param [Class] parent
      # @param [String] scope
      # @return [Class]
      def with_scope(parent, scope)
        klass_name = "#{scope}_grid".classify

        Dry::Core::ClassBuilder.new(parent: self, name: klass_name, namespace: parent).call.tap do |klass|
          klass.scope_parent parent
          klass.scope_name scope

          klass.permission_grids.each do |name, defn|
            klass.grid name, defn[:type], default: defn[:default]
          end
        end
      end

      private

      def build_permission_params_from(initial_value)
        case initial_value
        when Support::GlobalTypes::Bool
          permission_names.index_with { initial_value }
        when Hash
          initial_value.symbolize_keys.slice(*permission_names)
        else
          {}
        end
      end

      # @return [<String>]
      def calculate_available_actions
        own_actions = permission_names.map do |name|
          [scope.presence, name].compact.join(?.)
        end

        own_actions + super
      end
    end
  end
end
