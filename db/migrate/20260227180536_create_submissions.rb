# frozen_string_literal: true

class CreateSubmissions < ActiveRecord::Migration[7.2]
  def change
    create_enum :submission_state, %w[
      draft submitted under_review revision_requested approved rejected published
    ]

    create_enum :entity_submission_status, %w[
      unsubmitted submission_draft submission_published
    ]

    create_enum :submission_comment_role, %w[submitter reviewer]

    %i[communities collections items entities].each do |table_name|
      change_table table_name do |t|
        t.enum :submission_status, enum_type: :entity_submission_status, null: false, default: "unsubmitted"

        t.index :submission_status
      end
    end

    create_table :submissions, id: :uuid do |t|
      t.enum :state, enum_type: :submission_state, null: false, default: "draft"

      t.enum :kind, enum_type: :child_entity_kind, null: false

      t.references :submission_target, null: true, type: :uuid, foreign_key: { on_delete: :nullify }

      t.references :schema_version, null: false, type: :uuid, foreign_key: { on_delete: :restrict }

      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :restrict }

      t.references :parent_entity, polymorphic: true, null: true, type: :uuid

      t.references :entity, null: true, type: :uuid, polymorphic: true, index: { unique: true }

      t.references :collection, null: true, type: :uuid, foreign_key: { on_delete: :nullify }

      t.references :item, null: true, type: :uuid, foreign_key: { on_delete: :nullify }

      t.citext :title, null: false

      t.jsonb :metadata, null: false, default: {}

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index :state
    end

    build_transition_table_for :submission

    create_table :submission_comments, id: :uuid do |t|
      t.references :submission, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :restrict }

      t.bigint :position, null: false

      t.enum :role, enum_type: :submission_comment_role, null: false

      t.text :content, null: false

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index :role

      t.index %i[submission_id position], unique: true, name: "idx_submission_comments_positioning"
    end

    create_enum :submission_review_state, %w[pending approved rejected]

    create_table :submission_reviews, id: :uuid do |t|
      t.enum :state, enum_type: :submission_review_state, null: false, default: "pending"

      t.references :submission, null: false, type: :uuid, foreign_key: { on_delete: :cascade }, index: false
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :restrict }, index: false

      t.text :comment, null: true

      t.timestamp :requested_at

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[submission_id user_id], unique: true, name: "idx_submission_reviewers_uniqueness"

      t.index %i[user_id requested_at state], name: "idx_submission_reviews_user_requested_at_state"
    end

    build_transition_table_for :submission_review
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
