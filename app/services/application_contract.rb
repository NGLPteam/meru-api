# frozen_string_literal: true

# @abstract
class ApplicationContract < Dry::Validation::Contract
  config.types = Shared::TypeRegistry

  import_predicates_as_macros

  register_macro :entity do
    key.failure(:must_be_entity) unless value.kind_of?(::HierarchicalEntity)
  end

  register_macro :harvest_identifier_format do
    key.failure(:invalid_harvest_identifier) unless value.present? && Harvesting::Types::VALID_IDENTIFIER.match?(value)
  end

  register_macro :harvest_extraction_mapping_template do
    MeruAPI::Container["harvesting.extraction.validate_mapping_template"].(value) do |m|
      m.success do
        # Intentionally left blank. Field is valid.
      end

      m.failure :invalid_mapping_template do |_, error_keys|
        error_keys.each do |error_key|
          key.failure(error_key)
        end

        key.failure(:"extraction_mapping_template.invalid")
      end

      m.failure do
        # Fallback
        # simplecov:disable
        key.failure(:"extraction_mapping_template.invalid")
        # simplecov:enable
      end
    end
  end

  register_macro :harvest_frequency_expression do
    MeruAPI::Container["harvesting.schedules.parse"].(value) do |m|
      m.success do
        # Intentionally left blank. Field is valid.
      end

      m.failure :invalid_frequency_expression do |_, error_keys|
        Array(error_keys).each do |error_key|
          key.failure(error_key)
        end
      end

      m.failure do
        # Fallback
        # simplecov:disable
        key.failure(:"frequency_expression.invalid")
        # simplecov:enable
      end
    end
  end

  register_macro :slug_format do
    key.failure(:must_be_slug) unless Support::GlobalTypes::SLUG_PATTERN.match? value
  end

  register_macro :email_format do
    key.failure(:must_be_email) unless Support::GlobalTypes::EMAIL_PATTERN.match? value
  end

  register_macro :maybe_email_format do
    key.failure(:must_be_email) unless value.blank? || Support::GlobalTypes::EMAIL_PATTERN.match?(value)
  end

  register_macro :maybe_url_format do
    key.failure(:must_be_url) unless value.blank? || Support::GlobalTypes::URL_PATTERN.match?(value)
  end

  register_macro :orcid_format do
    key.failure(:must_be_orcid) unless value.blank? || Contributors::Types::ORCID_FORMAT.match?(value)
  end

  register_macro :tag_format do
    key.failure("cannot contain a comma") if key? && value.include?(?,)
  end

  register_macro :url_format do
    key.failure(:must_be_url) unless Support::GlobalTypes::URL_PATTERN.match?(value)
  end
end
