# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::Operations::UpdateGlobalConfiguration
    class UpdateGlobalConfiguration < ApplicationContract
      json do
        optional(:contribution_roles).maybe(:hash) do
          required(:controlled_vocabulary).value(:controlled_vocabulary)
          required(:default_item).value(:controlled_vocabulary_item)
          optional(:other_item).value(:controlled_vocabulary_item)
        end

        optional(:depositing).maybe(:hash) do
          required(:agreement).value(:safe_string)
        end

        optional(:entities).maybe(:hash) do
          required(:suppress_external_links).value(:bool)
        end

        optional(:institution).maybe(:hash) do
          required(:name).value(:safe_string)
        end

        optional(:site).maybe(:hash) do
          optional(:installation_name).value(:safe_string)
          optional(:installation_home_page_copy).value(:safe_string)
          optional(:provider_name).value(:safe_string)
          optional(:footer).maybe(:hash) do
            optional(:copyright_statement).value(:safe_string)
            optional(:description).value(:safe_string)
          end
        end

        optional(:theme).maybe(:hash) do
          required(:color).value(included_in?: Settings::Types::COLOR_SCHEMES)
          required(:font).value(included_in?: Settings::Types::FONT_SCHEMES)
        end
      end

      rule("contribution_roles.default_item") do
        vocab = values.dig(:contribution_roles, :controlled_vocabulary)

        next if value.blank? || vocab.blank? || value.controlled_vocabulary == vocab

        key.failure(:mismatched_vocabulary_item)
      end

      rule("contribution_roles.other_item") do
        vocab = values.dig(:contribution_roles, :controlled_vocabulary)

        next if value.blank? || vocab.blank? || value.controlled_vocabulary == vocab

        key.failure(:mismatched_vocabulary_item)
      end
    end
  end
end
