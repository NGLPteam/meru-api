# frozen_string_literal: true

class CreateContributorUserLinks < ActiveRecord::Migration[8.1]
  def change
    create_enum :contributor_user_linkage, %w[primary auxiliary]

    create_table :contributor_user_links, id: :uuid do |t|
      t.references :contributor, null: false, foreign_key: { on_delete: :cascade }, type: :uuid, index: { unique: true }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.enum :linkage, enum_type: "contributor_user_linkage", null: false, default: "auxiliary"

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[user_id contributor_id linkage], unique: true, where: "linkage = 'primary'", name: "index_contributor_user_primary_link"
    end
  end
end
