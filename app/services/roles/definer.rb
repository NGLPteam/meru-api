# frozen_string_literal: true

module Roles
  # Define a role with a specific list of permissions for scoped and global access.
  #
  # @api private
  # @see Roles::Calculator
  class Definer
    include Dry::Initializer[undefined: false].define -> do
      param :identifier, Dry::Types["coercible.string"]

      option :name, Dry::Types["coercible.string"], default: proc { identifier.to_s.titleize }
    end

    def call
      role[:identifier] = identifier
      role[:name] = name

      yield self

      role.deep_symbolize_keys!
      role.freeze

      return role
    end

    def access_control_list(*parts)
      role[:access_control_list] = grid_for(Roles::AccessControlList) do |acl|
        acl.allow!(*parts)

        yield acl if block_given?
      end
    end

    alias acl access_control_list

    def global_access_control_list(*parts)
      role[:global_access_control_list] = grid_for(Roles::GlobalAccessControlList) do |gacl|
        gacl.allow!(*parts)

        yield gacl if block_given?
      end
    end

    alias gacl global_access_control_list

    private

    # @see Roles::PermissionGridDefiner#call
    # @param [Class] klass
    # @return [Hash]
    def grid_for(klass)
      Roles::PermissionGridDefiner.new(klass).call do |grid|
        yield grid
      end[:acl]
    end

    def role
      @role ||= { access_control_list: {}, global_access_control_list: {} }
    end
  end
end
