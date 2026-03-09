# frozen_string_literal: true

module Templates
  # An individual entry in a {Templates::ManualList} for a given {Entity}.
  class ManualListEntry < ApplicationRecord
    include GenericAccessible
    include HasEphemeralSystemSlug
    include ReferencesEntityVisibility
    include TimestampScopes

    pg_enum! :template_kind, as: :template_kind, allow_blank: false, suffix: :template

    belongs_to :source, polymorphic: true,
      inverse_of: :manual_list_entries

    belongs_to :target, polymorphic: true,
      inverse_of: :incoming_manual_list_entries

    has_one_readonly :entity_visibility, primary_key: %i[target_type target_id], foreign_key: %i[entity_type entity_id]

    scope :by_source, ->(source) { where(source:) }
    scope :by_target, ->(target) { where(target:) }

    scope :by_list_name, ->(list_name) { where(list_name:) }
    scope :by_template_kind, ->(template_kind) { where(template_kind:) }

    scope :in_default_order, -> { reorder(template_kind: :asc, list_name: :asc, position: :asc) }
  end
end
