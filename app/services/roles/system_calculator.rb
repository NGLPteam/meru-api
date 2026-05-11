# frozen_string_literal: true

module Roles
  # @see Roles::CalculateSystem
  class SystemCalculator < Roles::Calculator
    # Admins can do anything in the system.
    # This role is not directly assignable, but is instead managed
    # by Keycloak.
    role! :admin do |r|
      r.acl ?*

      r.gacl ?*
    end

    role! :manager do |r|
      # A manager can do anything under its assigned hierarchy
      r.acl ?* do |acl|
        # Except delete the thing it is assigned to.
        acl.deny! "self.delete"
      end

      r.gacl "admin.access", "contributors.*", "roles.read", "users.read"
    end

    role! :editor do |r|
      r.acl do |acl|
        # An editor can read anything under its assigned hierarchy
        acl.allow! "*.read", "*.assets.read"
        # An editor can update any assigned entity as well as its subcollections and items
        acl.allow! "self.update", "collections.update", "items.update"
        # An editor can update any asset
        acl.allow! "*.assets.update"
      end

      r.gacl "admin.access", "contributors.read", "contributors.create", "contributors.update", "contributors.claim", "contributors.merge" do |gacl|
        gacl.deny! "contributors.delete"

        gacl.allow! "roles.read"
      end
    end

    role! :reviewer do |r|
      r.acl do |acl|
        # A reviewer can read anything under its assigned hierarchy
        acl.allow! "*.read"

        # A reviewer can review any assigned entity as well as its subcollections and items
        acl.allow! "self.review", "collections.review", "items.review"

        # A reviewer can read any assets under its assigned hierarchy
        acl.allow! "*.assets.read"
      end

      r.gacl "admin.access", "contributors.read", "contributors.claim", "roles.read"
    end

    role! :depositor do |r|
      r.acl do |acl|
        # A depositor can read anything under its assigned hierarchy
        acl.allow! "*.read"

        # A depositor can deposit to any assigned entity as well as its subcollections and items
        acl.allow! "self.deposit", "collections.deposit", "items.deposit"

        # A depositor can read any assets under its assigned hierarchy
        acl.allow! "*.assets.read"
      end

      r.gacl "admin.access", "contributors.read", "contributors.claim", "roles.read"
    end

    role! :author do |r|
      r.acl do |acl|
        # An author can update and read its own entity
        acl.allow! "self.update", "self.read", "self.assets.*"
      end

      r.gacl "admin.access", "contributors.read"
    end

    role! :reader do |r|
      r.acl "*.read", "*.assets.read"

      r.gacl "contributors.read", "roles.read"
    end
  end
end
