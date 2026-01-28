# frozen_string_literal: true

class CreateOrderingDateRanges < ActiveRecord::Migration[7.2]
  def change
    change_table :named_variable_dates do |t|
      t.index %i[entity_type entity_id path value precision], order: { precision: :desc },
        name: "index_named_variable_dates_ranging",
        include: %i[normalized],
        where: %[precision IS NOT NULL AND value IS NOT NULL]
    end

    create_view :ordering_date_ranges
  end
end
