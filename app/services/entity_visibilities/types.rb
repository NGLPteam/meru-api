# frozen_string_literal: true

module EntityVisibilities
  module Types
    extend ::Support::Typespace

    # When scoping, it only makes sense to scope by `hidden`
    # or `visible` for the specified time.
    ScopableVisibility = Support::GlobalTypes::Coercible::Symbol.enum(:hidden, :visible)

    State = ApplicationRecord.dry_pg_enum(:entity_visibility_state, default: "visible")
  end
end
