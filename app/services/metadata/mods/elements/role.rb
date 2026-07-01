# frozen_string_literal: true

module Metadata
  module MODS
    module Elements
      class Role < ::Metadata::MODS::Common::AbstractMapper
        attribute :role_terms, ::Metadata::MODS::Elements::RoleTerm, collection: true

        attribute :role_term, method: :derive_role_term

        xml do
          root "role"

          namespace "http://www.loc.gov/mods/v3", "mods"

          map_element "roleTerm", to: :role_terms
        end

        # @return [String, nil]
        def derive_role_term
          # simplecov:disable
          return if role_terms.blank?
          # simplecov:enable

          code = role_terms.detect(&:code)

          code&.content || role_terms.detect(&:text)&.content
        end
      end
    end
  end
end
