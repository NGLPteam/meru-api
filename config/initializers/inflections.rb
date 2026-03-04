# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "ANZ"
  inflect.acronym "API"
  inflect.acronym "CRUD"
  inflect.acronym "DOI"
  inflect.acronym "DSL"
  inflect.acronym "ETD"
  inflect.acronym "EISBN"
  inflect.acronym "GraphQL"
  inflect.acronym "HTML"
  inflect.acronym "ISBN"
  inflect.acronym "ISSN"
  inflect.acronym "IP"
  inflect.acronym "JATS"
  inflect.acronym "JSON"
  inflect.acronym "MDX"
  inflect.acronym "METS"
  inflect.acronym "MODS"
  inflect.acronym "OAIDC"
  inflect.acronym "OAIPMH"
  inflect.acronym "OAI"
  inflect.acronym "ORCID"
  inflect.acronym "NGLP"
  inflect.acronym "PDF"
  inflect.acronym "PREMIS"
  inflect.acronym "TOC"
  inflect.acronym "URL"
  inflect.acronym "APISchema"
  inflect.acronym "MeruAPI"
  inflect.acronym "VOG"
  inflect.acronym "XML"
  inflect.acronym "XPath"

  inflect.acronym "GTE"
  inflect.acronym "LTE"

  inflect.uncountable "JATS"
  inflect.uncountable "Metadata"
  inflect.uncountable "METS"
  inflect.uncountable "MODS"
  inflect.uncountable "PREMIS"
  inflect.uncountable "XML"

  inflect.irregular "table_of_contents", "tables_of_contents"
  inflect.irregular "type_of_resource", "types_of_resource"
end

URLValidator = ActiveModel::Validations::UrlValidator
