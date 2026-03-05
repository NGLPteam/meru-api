# frozen_string_literal: true

class CreateSubmissionTargets < ActiveRecord::Migration[7.2]
  def change
    create_enum :submission_target_state, %w[
      closed open
    ]

    create_enum :submission_deposit_mode, %w[
      direct
      descendant
    ]

    create_enum :depositor_request_state, %w[
      pending approved rejected
    ]

    change_table :global_configurations do |t|
      t.jsonb :depositing, null: false, default: {}
    end

    create_table :submission_targets, id: :uuid do |t|
      t.enum :state, enum_type: :submission_target_state, null: false, default: "closed"
      t.enum :deposit_mode, enum_type: :submission_deposit_mode, null: false, default: "direct"

      t.references :entity, null: false, polymorphic: true, type: :uuid, index: { unique: true }

      t.references :schema_version, null: false, type: :uuid, foreign_key: { on_delete: :restrict }

      t.references :community, null: true, type: :uuid, foreign_key: { to_table: :communities, on_delete: :restrict }, index: { unique: true}
      t.references :collection, null: true, type: :uuid, foreign_key: { to_table: :collections, on_delete: :restrict }, index: { unique: true }
      t.references :item, null: true, type: :uuid, foreign_key: { to_table: :items, on_delete: :restrict }, index: { unique: true }

      t.bigint :deposit_targets_count, null: false, default: 0
      t.bigint :reviewers_count, null: false, default: 0
      t.bigint :schema_versions_count, null: false, default: 0

      t.enum :allowed_child_kinds, enum_type: :child_entity_kind, null: false, array: true, default: []

      t.boolean :agreement_required, null: false, default: false

      t.text :agreement_content, null: true

      t.jsonb :description, null: false, default: {}

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index :state
    end

    build_transition_table_for :submission_target

    create_table :depositor_requests, id: :uuid do |t|
      t.enum :state, enum_type: :depositor_request_state, null: false, default: "pending"

      t.references :submission_target, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }

      t.text :message, null: true

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[submission_target_id user_id], unique: true, name: "idx_depositor_requests_uniqueness"
    end

    build_transition_table_for :depositor_request

    create_table :submission_deposit_targets, id: :uuid do |t|
      t.enum :deposit_mode, enum_type: :submission_deposit_mode, null: false, default: "direct"

      t.references :submission_target, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :entity, null: false, polymorphic: true, type: :uuid
      t.references :schema_version, null: false, type: :uuid, foreign_key: { on_delete: :restrict }

      t.references :community, null: true, type: :uuid, foreign_key: { to_table: :communities, on_delete: :restrict }
      t.references :collection, null: true, type: :uuid, foreign_key: { to_table: :collections, on_delete: :restrict }
      t.references :item, null: true, type: :uuid, foreign_key: { to_table: :items, on_delete: :restrict }

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[submission_target_id entity_type entity_id], unique: true, name: "idx_submission_deposit_targets_uniqueness"
    end

    create_table :submission_target_reviewers, id: :uuid do |t|
      t.references :submission_target, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :restrict }

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[submission_target_id user_id], unique: true, name: "idx_submission_target_reviewers_uniqueness"
    end

    create_table :submission_target_schema_versions, id: :uuid do |t|
      t.references :submission_target, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :schema_version, null: false, type: :uuid, foreign_key: { on_delete: :restrict }

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[submission_target_id schema_version_id], unique: true, name: "idx_submission_target_schema_versions_uniqueness"
    end
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
