# frozen_string_literal: true

module Templates
  # An ephemeral connection to {Templates::ManualListEntry}, derived from the
  # existence of a `manual_list_name` being set under the right conditions on
  # a given {TemplateDefinition}.
  class ManualList < ApplicationRecord
    include GenericAccessible
    include HasEphemeralSystemSlug
    include TimestampScopes

    pg_enum! :layout_kind, as: :layout_kind, allow_blank: false, suffix: :layout

    pg_enum! :template_kind, as: :template_kind, allow_blank: false, suffix: :template

    belongs_to :template_definition, polymorphic: true,
      inverse_of: :manual_list

    belongs_to :layout_definition, polymorphic: true,
      inverse_of: :manual_lists

    scope :by_layout_kind, ->(layout_kind) { where(layout_kind:) }
    scope :by_list_name, ->(list_name) { where(list_name:) }
    scope :by_template_kind, ->(template_kind) { where(template_kind:) }
  end
end
