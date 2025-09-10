# frozen_string_literal: true

class CreateFrontendRevalidations < ActiveRecord::Migration[7.2]
  def change
    create_enum :frontend_revalidation_kind, ["entity", "instance"]

    create_table :frontend_revalidations, id: :uuid do |t|
      t.enum :kind, enum_type: "frontend_revalidation_kind", null: false

      t.boolean :manual, null: false, default: false

      t.timestamp :revalidated_at

      t.references :entity, polymorphic: true, null: true, type: :uuid

      t.jsonb :params

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
