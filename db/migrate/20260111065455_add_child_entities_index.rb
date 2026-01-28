# frozen_string_literal: true

class AddChildEntitiesIndex < ActiveRecord::Migration[7.2]
  def change
    change_table :entities do |t|
      t.index %i[entity_type entity_id],
        name: "index_entities_for_child_entity_tuples",
        where: "scope IN ('collections', 'items')"
    end
  end
end
