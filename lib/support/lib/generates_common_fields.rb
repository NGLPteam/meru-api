# frozen_string_literal: true

module Support
  # A concern for generators that have certain common fields that always behave
  # the same way.
  #
  # Currently that is:
  #
  # - `name` (string, optionally unique)
  # - `identifier` (string, always unique)
  # - `description` (string, optional and nullable)
  module GeneratesCommonFields
    extend ActiveSupport::Concern

    included do
      class_option :derives_identifier_from_name, type: :boolean, default: false
      class_option :has_name, type: :boolean, default: false
      class_option :has_title, type: :boolean, default: false
      class_option :optional_description, type: :boolean, default: false
      class_option :unique_identifier, type: :boolean, default: false
      class_option :unique_title, type: :boolean, default: false
    end

    private

    # @api private
    # Pass common field options to a subgenerator that
    # also implements {Support::GeneratesCommonFields}.
    # @return [<String>]
    def common_field_options
      [].tap do |arr|
        arr << "--derives-identifier-from-name" if derives_identifier_from_name?
        arr << "--has-name" if has_name?
        arr << "--has-title" if has_title?
        arr << "--optional-description" if has_optional_description?
        arr << "--unique-identifier" if has_unique_identifier?
        arr << "--unique-title" if has_unique_title?
      end
    end

    def derives_identifier_from_name?
      should_add_common_fields? && options[:derives_identifier_from_name]
    end

    def has_common_fields?
      has_optional_description? || has_name? || has_title? || has_unique_identifier? || has_unique_title?
    end

    def has_optional_description?
      should_add_common_fields? && options[:optional_description]
    end

    def has_name?
      should_add_common_fields? && (options[:has_name] || derives_identifier_from_name?)
    end

    def has_title?
      should_add_common_fields? && (options[:has_title] || has_unique_title?)
    end

    def has_unique_identifier?
      should_add_common_fields? && (options[:unique_identifier] || derives_identifier_from_name?)
    end

    def has_unique_title?
      should_add_common_fields? && options[:unique_title]
    end

    def should_add_common_fields?
      true
    end
  end
end
