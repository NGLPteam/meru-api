# frozen_string_literal: true

class AddCacheWarmingToEntities < ActiveRecord::Migration[7.2]
  TABLES = %i[communities collections items].freeze

  create_enum :cache_warming_status, %w[default on off]

  def change
    TABLES.each do |table|
      change_table table do |t|
        t.boolean :cache_warming_default_enabled, null: false, default: table == :communities

        t.boolean :cache_warming_enabled, null: false, default: false

        t.enum :cache_warming_status, enum_type: :cache_warming_status, null: false, default: "default"
      end
    end
  end
end
