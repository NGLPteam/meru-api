# frozen_string_literal: true

module Schemas
  module Properties
    # A union type that dispatches betweeen all the possible types
    #
    # @see Schemas::Properties::Scalar::Base
    ScalarDefinition = StoreModel.one_of do |json|
      case json.fetch(:type, json["type"])
      when "asset" then Schemas::Properties::Scalar::Asset
      when "assets" then Schemas::Properties::Scalar::Assets
      when "boolean" then Schemas::Properties::Scalar::Boolean
      when "contributor" then Schemas::Properties::Scalar::Contributor
      when "contributors" then Schemas::Properties::Scalar::Contributors
      when "controlled_vocabulary" then Schemas::Properties::Scalar::ControlledVocabulary
      when "controlled_vocabularies" then Schemas::Properties::Scalar::ControlledVocabularies
      when "date" then Schemas::Properties::Scalar::Date
      when "entities" then Schemas::Properties::Scalar::Entities
      when "entity" then Schemas::Properties::Scalar::Entity
      when "email" then Schemas::Properties::Scalar::Email
      when "float" then Schemas::Properties::Scalar::Float
      when "full_text" then Schemas::Properties::Scalar::FullText
      when "integer" then Schemas::Properties::Scalar::Integer
      when "markdown" then Schemas::Properties::Scalar::Markdown
      when "multiselect" then Schemas::Properties::Scalar::Multiselect
      when "select" then Schemas::Properties::Scalar::Select
      when "string" then Schemas::Properties::Scalar::String
      when "tags" then Schemas::Properties::Scalar::Tags
      when "timestamp" then Schemas::Properties::Scalar::Timestamp
      when "url" then Schemas::Properties::Scalar::URL
      when "variable_date" then Schemas::Properties::Scalar::VariableDate
      else
        # simplecov:disable
        Schemas::Properties::Scalar::Unknown
        # simplecov:enable
      end
    end

    class << ScalarDefinition
      # Expose the block so it can be reused
      attr_reader :block
    end
  end
end
