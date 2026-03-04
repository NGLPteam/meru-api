# frozen_string_literal: true

class AddDepositorAndReviewerRoles < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
    ALTER TYPE role_identifier ADD VALUE IF NOT EXISTS 'reviewer' AFTER 'editor';
    ALTER TYPE role_identifier ADD VALUE IF NOT EXISTS 'depositor' AFTER 'reviewer';
    SQL
  end

  def down
    # Intentionally left blank, this cannot be reversed.
  end
end
