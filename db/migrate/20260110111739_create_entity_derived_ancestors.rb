class CreateEntityDerivedAncestors < ActiveRecord::Migration[7.2]
  def change
    create_view :entity_derived_ancestors
  end
end
