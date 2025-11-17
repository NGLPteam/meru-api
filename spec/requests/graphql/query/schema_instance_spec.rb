# frozen_string_literal: true

RSpec.describe "Schema Instances", type: :request do
  let!(:article) { FactoryBot.create :item, schema: "nglp:journal_article" }

  let!(:graphql_variables) { { slug: article.system_slug } }

  let!(:query) do
    <<~GRAPHQL
    query getArticleSchemaProps($slug: Slug!) {
      article: item(slug: $slug) {
        body: schemaProperty(fullPath: "body") {
          ...PropInfoFragment
        }

        metaCollected: schemaProperty(fullPath: "meta.collected") {
          ... PropInfoFragment
        }

        unknown: schemaProperty(fullPath: "unknown.path") {
          ... PropInfoFragment
        }

        schemaInstanceContext {
          assets {
            kind
            label
            value
          }

          contributors {
            kind
            label
            value
          }

          entityId

          fieldValues

          schemaVersionSlug

          validity {
            valid
            errors {
              message
            }
          }
        }
      }
    }

    fragment PropInfoFragment on SchemaProperty {
      __typename

      ... on ScalarProperty {
        fullPath
        type
      }

      ... on StringProperty {
        content
      }

      ... on FullTextProperty {
        fullText {
          kind
          lang
          content
        }
      }

      ... on VariableDateProperty {
        dateWithPrecision {
          precision
          value
        }
      }
    }
    GRAPHQL
  end

  let!(:expected_shape) do
    gql.query do |q|
      q.prop :article do |art|
        art.prop :body do |bod|
          bod.typename("FullTextProperty")

          bod[:type] = "FULL_TEXT"
          bod[:full_path] = "body"
          bod[:full_text] = be_blank
        end

        art.prop :meta_collected do |mc|
          mc.typename("VariableDateProperty")
          mc[:type] = "VARIABLE_DATE"
          mc[:full_path] = "meta.collected"

          mc.prop :date_with_precision do |date|
            date[:precision] = "NONE"
            date[:value] = be_blank
          end
        end

        art[:unknown] = be_blank

        art.prop :schema_instance_context do |sic|
          sic[:assets] = be_blank
          sic[:contributors] = be_blank
          sic[:entity_id] = article.to_encoded_id
          sic[:field_values] = be_blank
          sic[:schema_version_slug] = article.schema_version.system_slug

          sic.prop :validity do |v|
            v[:valid] = true
            v[:errors] = be_blank
          end
        end
      end
    end
  end

  it "can retrieve information about incomplete schemas" do
    expect_request! do |req|
      req.data! expected_shape
    end
  end
end
