# frozen_string_literal: true

module Schemas
  module Properties
    module References
      module Entities
        module Types
          extend ::Support::Typespace

          # Parse the name for an ancestor origin.
          ANCESTOR = /\Aancestor\.(?<ancestor_name>[a-z][a-z0-9_]*[a-z])\z/

          AncestorOrigin = Coercible::String.constrained(format: ANCESTOR)

          StaticOrigin = Coercible::String.enum("community", "parent", "self")

          Origin = StaticOrigin | AncestorOrigin
        end
      end
    end
  end
end
