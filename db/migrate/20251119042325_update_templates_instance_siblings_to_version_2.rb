# frozen_string_literal: true

class UpdateTemplatesInstanceSiblingsToVersion2 < ActiveRecord::Migration[7.2]
  def change
    update_view :templates_instance_siblings, version: 2, revert_to_version: 1
  end
end
