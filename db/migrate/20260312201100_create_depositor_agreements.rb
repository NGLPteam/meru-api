# frozen_string_literal: true

class CreateDepositorAgreements < ActiveRecord::Migration[7.2]
  def change
    create_enum :depositor_agreement_state, %w[pending accepted]

    create_table :depositor_agreements, id: :uuid do |t|
      t.references :submission_target, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.references :user, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.enum :state, enum_type: :depositor_agreement_state, null: false, default: "pending"

      t.timestamp :last_accepted_at

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[submission_target_id user_id], unique: true, name: "idx_depositor_agreements_uniqueness"
    end

    build_transition_table_for :depositor_agreement
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
