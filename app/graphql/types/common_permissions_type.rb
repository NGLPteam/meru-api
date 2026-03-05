# frozen_string_literal: true

module Types
  module CommonPermissionsType
    include Types::BaseInterface

    description <<~TEXT
    Common permissions shared on most models.
    TEXT

    expose_authorization_rule :update?, <<~TEXT
    Whether the current user has permission to update this record.
    TEXT

    expose_authorization_rule :destroy?, <<~TEXT
    Whether the current user has permission to destroy this record.
    TEXT
  end
end
