# frozen_string_literal: true

module Templates
  class DefinitionDigest < ApplicationRecord
    include GenericAccessible
    include HasEphemeralSystemSlug
    include TimestampScopes

    belongs_to :layout_definition, polymorphic: true, inverse_of: :template_definition_digests

    belongs_to :template_definition, polymorphic: true, inverse_of: :definition_digest

    pg_enum! :layout_kind, as: :layout_kind, allow_blank: false, suffix: :layout

    pg_enum! :template_kind, as: :template_kind, allow_blank: false, suffix: :template
  end
end
