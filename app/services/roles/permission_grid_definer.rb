# frozen_string_literal: true

module Roles
  class PermissionGridDefiner
    include Dry::Initializer[undefined: false].define -> do
      param :available_actions, Roles::Types::GridList
    end

    include MeruAPI::Deps[
      quote_permission_query: "roles.quote_permission_query"
    ]

    # @return [Roles::AnonymousGrid]
    def call
      @acl = ::Support::PropertyHash.new

      yield self

      allowed_actions = @acl.paths.select do |path|
        @acl[path].present?
      end

      attrs = {
        available_actions:,
        allowed_actions:,
        acl: @acl.to_h.deep_symbolize_keys,
      }

      return Roles::AnonymousGrid.new(attrs)
    end

    # @param [<"*", Roles::Types::PermissionName, Roles::Types::PermissionQuery>] paths
    # @return [void]
    def allow!(*paths)
      each_path_in paths do |path|
        set_path! path, true
      end
    end

    # @param [<"*", Roles::Types::PermissionName, Roles::Types::PermissionQuery>] paths
    # @return [void]
    def deny!(*paths)
      each_path_in paths do |path|
        set_path! path, false
      end
    end

    private

    # @param [<"*", Roles::Types::PermissionName, Roles::Types::PermissionQuery>] paths
    # @return [void]
    def each_path_in(paths)
      paths.flatten!

      return if paths.none?

      paths.each do |path|
        yield path
      end

      return
    end

    # @param ["*", Roles::Types::PermissionName, Roles::Types::PermissionQuery] path
    # @param [Boolean] value
    def set_path!(path, value)
      permissions = matched_permissions_for(path)

      Array(permissions).each do |found_path|
        @acl[found_path] = value
      end
    end

    def matched_permissions_for(path)
      case path
      when ?*
        available_actions
      when Roles::Types::PermissionName
        available_actions.detect do |permission|
          permission == path
        end.then { |x| Array(x) }
      when Roles::Types::PermissionQuery
        pattern = quote_permission_query.call path

        available_actions.grep(pattern)
      else
        # simplecov:disable
        raise ArgumentError, "Don't know how to match permission path: #{path.inspect}"
        # simplecov:enable
      end
    end
  end
end
