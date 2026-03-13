# frozen_string_literal: true

class AdjustSubmissionReviewState < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
    ALTER TYPE submission_review_state ADD VALUE IF NOT EXISTS 'revision_requested' AFTER 'pending';
    SQL
  end

  def down
    # Intentionally left blank.
  end
end
