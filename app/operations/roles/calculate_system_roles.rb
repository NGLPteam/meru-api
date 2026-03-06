# frozen_string_literal: true

module Roles
  # rubocop:disable Metrics/MethodLength
  class CalculateSystemRoles
    def call
      mapper = Roles::Mapper.new

      roles = mapper.call do |m|
        m.role! :admin do |r|
          r.acl ?*

          r.gacl ?*
        end

        m.role! :manager do |r|
          # A manager can do anything under its assigned hierarchy
          r.acl ?* do |acl|
            # Except delete the thing it is assigned to.
            acl.deny! "self.delete"
          end

          r.gacl "admin.access", "contributors.*", "roles.read", "users.read"
        end

        m.role! :editor do |r|
          r.acl do |acl|
            # An editor can read anything under its assigned hierarchy
            acl.allow! "*.read", "*.assets.read"
            # An editor can update any assigned entity as well as its subcollections and items
            acl.allow! "self.update", "collections.update", "items.update"
            # An editor can update any asset
            acl.allow! "*.assets.update"
          end

          r.gacl "admin.access", "contributors.read", "contributors.create", "contributors.update" do |gacl|
            gacl.deny! "contributors.delete"

            gacl.allow! "roles.read"
          end
        end

        m.role! :reviewer do |r|
          r.acl do |acl|
            # A reviewer can read anything under its assigned hierarchy
            acl.allow! "*.read"

            # A reviewer can review any assigned entity as well as its subcollections and items
            acl.allow! "self.review", "collections.review", "items.review"

            # A reviewer can read any assets under its assigned hierarchy
            acl.allow! "*.assets.read"
          end

          r.gacl "admin.access", "contributors.read", "roles.read"
        end

        m.role! :depositor do |r|
          r.acl do |acl|
            # A depositor can read anything under its assigned hierarchy
            acl.allow! "*.read"

            # A depositor can deposit to any assigned entity as well as its subcollections and items
            acl.allow! "self.deposit", "collections.deposit", "items.deposit"

            # A depositor can read any assets under its assigned hierarchy
            acl.allow! "*.assets.read"
          end

          r.gacl "admin.access", "contributors.read", "roles.read"
        end

        m.role! :reader do |r|
          r.acl "*.read", "*.assets.read"

          r.gacl "contributors.read", "roles.read"
        end
      end

      return roles
    end
  end
  # rubocop:enable Metrics/MethodLength
end
