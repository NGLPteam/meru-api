# frozen_string_literal: true

class CreateSubmissionPublications < ActiveRecord::Migration[7.2]
  def change
    create_enum :submission_batch_publication_state, ["pending", "batched", "finished"]

    create_enum :submission_publication_state, ["pending", "batched", "success", "failure"]

    create_table :submission_batch_publications, id: :uuid do |t|
      t.references :submission_target, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :user, null: true, foreign_key: { on_delete: :nullify }, type: :uuid

      t.enum :state, enum_type: "submission_batch_publication_state", null: false, default: "pending"

      t.bigint :publications_count, null: false, default: 0

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    build_transition_table_for :submission_batch_publication

    create_table :submission_publications, id: :uuid do |t|
      t.references :submission, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :user, null: true, foreign_key: { on_delete: :nullify }, type: :uuid
      t.references :submission_batch_publication, null: true, foreign_key: { on_delete: :nullify }, type: :uuid

      t.enum :state, enum_type: "submission_publication_state", null: false, default: "pending"

      t.bigint :batch_position, null: true

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    build_transition_table_for :submission_publication
  end

  private

  def build_transition_table_for(base)
    enum_type = :"#{base}_state"

    create_table :"#{base}_transitions", id: :uuid do |t|
      t.references base, null: false, type: :uuid, foreign_key: { on_delete: :cascade }, index: false
      t.references :user, null: true, type: :uuid, foreign_key: { on_delete: :nullify }

      t.boolean :most_recent, null: false
      t.integer :sort_key, null: false
      t.enum :from_state, enum_type:, null: true
      t.enum :to_state, enum_type:, null: false
      t.jsonb :metadata

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %I(#{base}_id sort_key), unique: true, name: "idx_#{base}_transitions_parent_sort"
      t.index %I(#{base}_id most_recent), unique: true, where: "most_recent", name: "idx_#{base}_transitions_parent_most_recent"
    end
  end
end
