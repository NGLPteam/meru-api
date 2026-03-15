# frozen_string_literal: true

module Roles
  module ComposesGrids
    extend ActiveSupport::Concern

    included do
      extend Dry::Core::ClassAttributes

      include StoreModel::Model

      # @!scope class
      # @!attribute [r] permission_grids
      # @return [{ Symbol => Roles::Grid }]
      defines :permission_grids, type: Roles::Types::Hash

      defines :permission_names, type: Roles::Types::Array.of(Roles::Types::Symbol)

      defines :scope_parent, type: Roles::Types::Class.optional

      defines :scope_name, type: Roles::Types::Symbol.optional

      permission_grids Dry::Core::Constants::EMPTY_HASH
      permission_names Dry::Core::Constants::EMPTY_ARRAY

      scope_parent nil

      scope_name nil
    end

    # @param [#to_s]
    # @return [Boolean]
    def [](name)
      attributes[name.to_s]
    end

    # @param [#to_s, nil] scope
    # @return [<String>]
    def calculate_allowed_actions
      permissions.reduce [] do |actions, grant|
        actions | grant.allowed_actions
      end
    end

    alias allowed_actions calculate_allowed_actions

    # @return [{ Symbol => Roles::Grid }]
    def permission_grids
      self.class.permission_grid_names.index_with do |grid_name|
        public_send(grid_name)
      end
    end

    # @return [<Permission::Grant>]
    def permissions
      permission_grids.flat_map do |_, grid|
        grid.permissions
      end
    end

    # @return [String]
    def scope = self.class.scope

    private

    # @param [#to_s, nil] scope
    # @param [#to_s] name
    # @return [String]
    def compose_scope(scope, name)
      scope.present? ? "#{scope}.#{name}" : name.to_s
    end

    module ClassMethods
      # @see #build_with
      # @return [Roles::ComposesGrids]
      def allow_everything
        build_with true
      end

      # @!scope class
      # @!attribute [r] available_actions
      # @return [<String>]
      def available_actions
        @available_actions ||= calculate_available_actions
      end

      # @param [Boolean, { Symbol => Boolean }, <String>] initial_value
      # @return [Roles::ComposesGrids]
      def build_with(initial_value)
        params = build_params_from initial_value

        new params
      end

      # @param [Boolean, { Symbol => Boolean }, <String>] initial_value
      # @return [{ Symbol => Boolean }]
      def build_params_from(initial_value)
        permission_grids.each_with_object({}) do |(grid_name, definition), h|
          specific_value = initial_value.kind_of?(Hash) && grid_name.in?(initial_value) ? initial_value[grid_name] : initial_value

          h[grid_name] = definition[:type].build_params_from(specific_value)
        end
      end

      # Instantiate a new ACL based on the definer block.
      #
      # @yield [acl] Yield the definer class
      # @yieldparam [Roles::PermissionGridDefiner] acl
      # @yieldreturn [void]
      # @return [Roles::ComposesGrids]
      def define(*roles)
        raw = Roles::PermissionGridDefiner.new(self).call do |acl|
          acl.allow!(*roles) if roles.any?

          yield acl if block_given?
        end

        new raw[:acl]
      end

      # @param [#to_sym] name
      # @param [Class] type must implement {Roles::Grid}
      # @param [Boolean, { Symbol => Boolean }] default (@see Roles::Grid::ClassMethods#build_params_for)
      # @return [void]
      def grid(name, type = Roles::PermissionGrid, default: {})
        name = name.to_sym

        type = Roles::Grid::INHERITED[type].with_scope(self, name)

        default_value = type.build_params_from(default)

        attribute name, type.to_type, default: default_value

        define_grid! name, type:, default: default_value
      end

      # @return [<String>]
      def permission_grid_names = permission_grids.keys

      # @return [<Class>]
      def permission_grid_types = permission_grids.values.pluck(:type)

      # @return [String]
      def scope = [scope_parent&.scope, scope_name].map(&:presence).compact.join(?.)

      private

      # @return [<String>]
      def calculate_available_actions
        permission_grid_types.flat_map do |grid_type|
          grid_type.__send__ :calculate_available_actions
        end
      end

      # @param [Symbol] name
      # @param [Hash] options
      # @option options [Class] :type
      # @option options [Boolean, { Symbol => Boolean }] :default
      # @return [void]
      def define_grid!(name, **options)
        new_grids = permission_grids.merge(name => options)

        permission_grids new_grids.freeze

        recalculate_available_actions!
      end

      # @return [void]
      def recalculate_available_actions!
        @available_actions = calculate_available_actions
      end
    end
  end
end
