# frozen_string_literal: true

module Frontend
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    Entity = Instance(HierarchicalEntity)

    RevalidationKind = ApplicationRecord.dry_pg_enum("frontend_revalidation_kind")
  end
end
