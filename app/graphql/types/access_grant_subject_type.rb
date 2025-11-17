# frozen_string_literal: true

module Types
  module AccessGrantSubjectType
    include Types::BaseInterface

    description <<~TEXT
    An access grant subject is a person or group to which access for a specific entity
    (and all its children) has been granted.
    TEXT

    field :all_access_grants, resolver: Resolvers::AccessGrants::SubjectResolver do
      description "A polymorphic connection for access grants from a subject"
    end

    field :primary_role, Types::RoleType, null: true do
      description "The primary role associated with this subject."
    end

    field :assignable_roles, [Types::RoleType, { null: false }], null: false do
      description <<~TEXT
      The roles this user has access to assign based on their `primaryRole`,
      outside of any hierarchical context.

      When actually assigning roles for an entity, you should use `Entity.assignableRoles`,
      because it will ensure that the user sufficient permissions at that level.
      TEXT
    end

    load_association! :assignable_roles

    load_association! :primary_role
  end
end
