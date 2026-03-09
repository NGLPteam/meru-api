# frozen_string_literal: true

module Layouts
  class InstanceDigest < ApplicationRecord
    include GenericAccessible
    include HasEphemeralSystemSlug
    include TimestampScopes

    belongs_to :entity, polymorphic: true, inverse_of: :layout_instance_digests

    belongs_to :layout_definition, polymorphic: true, inverse_of: :instance_digests
    belongs_to :layout_instance, polymorphic: true, inverse_of: :instance_digest

    pg_enum! :layout_kind, as: :layout_kind, allow_blank: false, suffix: :layout
  end
end
