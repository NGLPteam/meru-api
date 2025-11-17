# frozen_string_literal: true

module Types
  module AccessGrantType
    include Types::BaseInterface

    description <<~TEXT
    An access grant is a combination of an Entity, a Role, and a Subject. It determines permissions for
    said subject at the specific point in the hierarchy, and any child entities will inherit that role
    as its accessControlList defines.
    TEXT

    field :entity, Types::EntityType, null: false, method: :accessible do
      description "The polymorphic entity to which access has been granted"
    end

    field :role, Types::RoleType, null: false do
      description "The role the subject has been assigned"
    end

    field :subject, Types::AccessGrantSubjectType, null: false do
      description "The polymorphic subject that has been granted access"
    end
  end
end
