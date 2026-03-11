# frozen_string_literal: true

module Roles
  module Types
    extend ::Support::Typespace

    PERMISSION_PART = /(?:[a-z]+?[a-z_]+[a-z]+)/

    PERMISSION_FORMAT = /\A(?<scope>(?<part>#{PERMISSION_PART})(?:\.\g<part>)*?)\.(?<name>\g<part>)\z/

    PERMISSION_QUERY_PART = /(?:\*|#{PERMISSION_PART})/

    PERMISSION_QUERY = /\A#{PERMISSION_QUERY_PART}(?:\.#{PERMISSION_QUERY_PART})+\z/

    GRID = ->(klass) do
      Constructor(klass) do |value|
        case value
        when klass then value
        else
          klass.build_with(value)
        end
      end
    end

    ACL = GRID[Roles::AccessControlList]

    GACL = GRID[Roles::GlobalAccessControlList]

    PermissionName = String.constrained(format: PERMISSION_FORMAT)

    PermissionList = Array.of(PermissionName)

    PermissionQuery = String.constrained(format: PERMISSION_QUERY)

    GridList = PermissionList.constructor do |value|
      case value
      when Roles::Types.Interface(:available_actions) then value.available_actions
      else
        value
      end
    end

    PolicyPredicate = Symbol

    EffectivePermissionMap = Hash.map(PermissionName, PolicyPredicate)
  end
end
