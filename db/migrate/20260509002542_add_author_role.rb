# frozen_string_literal: true

class AddAuthorRole < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
    ALTER TYPE role_identifier ADD VALUE IF NOT EXISTS 'author' BEFORE 'reader';
    SQL
  end

  def down
    # intentionally left blank
  end
end
