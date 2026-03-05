# frozen_string_literal: true

RSpec.describe Mutations::UpdateGlobalConfiguration, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation updateGlobalConfiguration($input: UpdateGlobalConfigurationInput!) {
    updateGlobalConfiguration(input: $input) {
      globalConfiguration {
        contributionRoles {
          controlledVocabulary {
            id
          }

          defaultItem {
            id
          }

          otherItem {
            id
          }
        }

        depositing {
          agreement
        }

        entities {
          suppressExternalLinks
        }

        institution {
          name
        }

        logo {
          original {
            ... ImageFragment
          }

          sansText {
            ... ImageSizeFragment
          }

          withText {
            ... ImageSizeFragment
          }
        }

        site {
          installationName
          installationHomePageCopy
          logoMode
          providerName

          footer {
            copyrightStatement
            description
          }
        }

        theme {
          color
          font
        }
      }

      ... ErrorFragment
    }
  }

  fragment ImageSizeFragment on ImageSize {
    size

    alt

    height

    width

    webp {
      ... ImageDerivativeFragment
    }

    png {
      ... ImageDerivativeFragment
    }
  }

  fragment ImageDerivativeFragment on ImageDerivative {
    ... ImageFragment

    format

    size

    maxHeight
    maxWidth
  }

  fragment ImageFragment on Image {
    alt
    height
    width
    url
  }
  GRAPHQL

  let!(:color) { "blue" }
  let!(:font) { "style2" }
  let!(:institution_name) { "Some Institution Name" }
  let(:site_logo_mode) { "NONE" }
  let(:deposit_agreement) { "Some deposit agreement text that users must agree to when depositing." }
  let!(:provider_name) { "Some Provider Name" }
  let!(:installation_name) { "Some Installation Name" }
  let!(:installation_home_page_copy) { "Some installation copy that appears on the home page." }
  let!(:footer_copyright_statement) { "Some Copyright Statement" }
  let!(:footer_description) { "Some Footer Description" }
  let!(:footer) do
    {
      copyright_statement: footer_copyright_statement,
      description: footer_description,
    }
  end

  let(:suppress_external_links) { false }

  let_mutation_input!(:clear_logo) { false }

  let_mutation_input!(:depositing) do
    { agreement: deposit_agreement }
  end

  let_mutation_input!(:entities) { { suppress_external_links:, } }

  let_mutation_input!(:institution) { { name: institution_name } }

  let_mutation_input!(:logo) { nil }
  let_mutation_input!(:logo_metadata) { { alt: "some text" } }

  let_mutation_input!(:site) do
    {
      installation_name:,
      installation_home_page_copy:,
      logo_mode: site_logo_mode,
      provider_name:,
      footer:,
    }
  end

  let_mutation_input!(:theme) do
    { color:, font: }
  end

  let!(:expected_depositing) { depositing }
  let!(:expected_entities) { entities }
  let!(:expected_footer) { footer }
  let(:expected_institution) { institution }
  let(:expected_site) { site.merge(footer: expected_footer) }
  let(:expected_theme) { theme }
  let(:expected_global_configuration) do
    {
      depositing: expected_depositing,
      entities: expected_entities,
      institution: expected_institution,
      site: expected_site,
      theme: expected_theme,
    }
  end

  let(:expected_errors) { be_blank }

  let(:has_errors) { false }

  let(:expected_shape) do
    gql.mutation :update_global_configuration, no_errors: !has_errors do |m|
      m[:global_configuration] = expected_global_configuration
      m[:attribute_errors] = expected_errors
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :update_global_configuration
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! keep_the_same { GlobalConfiguration.fetch.updated_at }
      end
    end
  end

  shared_examples_for "an authorized mutation" do
    it "updates the config" do
      expect_request! do |req|
        req.effect! keep_the_same { GlobalConfiguration.fetch.logo }
        req.effect! keep_the_same { GlobalConfiguration.fetch.logo_metadata }
        req.effect! change { GlobalConfiguration.fetch.site.as_json }
        req.effect! change { GlobalConfiguration.fetch.theme.as_json }

        req.data! expected_shape
      end
    end

    context "when providing a logo" do
      let(:logo) { graphql_upload_from "spec", "data", "lorempixel.jpg" }

      let(:expected_logo_mode) { "WITH_TEXT" }

      let(:expected_shape) do
        gql.mutation :update_global_configuration do |m|
          m.prop :global_configuration do |gc|
            gc.prop :logo do |l|
              l.prop :original do |o|
                o[:url] = be_present
              end
            end

            gc.prop :site do |s|
              s[:logo_mode] = expected_logo_mode
            end
          end
        end
      end

      it "uploads the logo and sets the mode" do
        expect_request! do |req|
          req.effect! change { GlobalConfiguration.fetch.logo.present? }.from(false).to(true)
          req.effect! change { GlobalConfiguration.fetch.site.logo_mode }.from("none").to("with_text")

          req.data! expected_shape
        end
      end

      context "when also providing a mode" do
        let(:site_logo_mode) { "SANS_TEXT" }

        let(:expected_logo_mode) { site_logo_mode }

        it "uploads the logo and sets the mode" do
          expect_request! do |req|
            req.effect! change { GlobalConfiguration.fetch.logo.present? }.from(false).to(true)
            req.effect! change { GlobalConfiguration.fetch.site.logo_mode }.from("none").to("sans_text")

            req.data! expected_shape
          end
        end
      end
    end

    context "when supplying a null value for certain fields" do
      let!(:institution_name) { nil }

      let(:expected_institution) { institution.merge(name: "") }

      it "ensures it is always a string" do
        expect_request! do |req|
          req.effect! keep_the_same { GlobalConfiguration.fetch.institution.name }

          req.data! expected_shape
        end
      end
    end

    context "when omitting site but providing theme" do
      let(:mutation_input) do
        { theme: }
      end

      let(:expected_institution) { GlobalConfiguration.fetch.institution.as_json }

      let(:expected_site) do
        GlobalConfiguration.fetch.site.then do |site|
          site.as_json.merge("logo_mode" => "NONE")
        end
      end

      it "partially updates the config" do
        expect_request! do |req|
          req.effect! keep_the_same { GlobalConfiguration.fetch.site.as_json }
          req.effect! change { GlobalConfiguration.fetch.theme.as_json }

          req.data! expected_shape
        end
      end
    end

    context "when omitting footer" do
      before do
        config = GlobalConfiguration.fetch

        config.site.footer.description = footer_description

        config.save!
      end

      let!(:footer) { nil }

      let(:expected_footer) { { description: footer_description } }

      it "does not clobber existing values" do
        expect_the_default_request.to keep_the_same { GlobalConfiguration.fetch.site.footer.as_json }

        expect_graphql_data expected_shape
      end
    end

    context "when providing nil as a theme" do
      let(:theme) { nil }
      let(:expected_theme) { GlobalConfiguration.fetch.theme.as_json }

      it "partially updates the config" do
        expect_the_default_request.to change { GlobalConfiguration.fetch.site.as_json }.and keep_the_same { GlobalConfiguration.fetch.theme.as_json }

        expect_graphql_data expected_shape
      end
    end

    shared_context "an invalid request" do
      let(:expected_global_configuration) { nil }

      it "fails to update" do
        expect_the_default_request.to keep_the_same { GlobalConfiguration.fetch.site.as_json }.and keep_the_same { GlobalConfiguration.fetch.theme.as_json }

        expect_graphql_data expected_shape
      end
    end

    context "when providing an invalid color" do
      include_context "an invalid request"

      let(:color) { "something invalid" }

      let(:expected_errors) do
        gql.attribute_errors do |eb|
          eb.error "theme.color" do |e|
            e.included_in Settings::Types::COLOR_SCHEMES
          end
        end
      end
    end

    context "when providing an invalid font" do
      include_context "an invalid request"

      let(:font) { "something invalid" }

      let(:expected_errors) do
        gql.attribute_errors do |eb|
          eb.error "theme.font" do |e|
            e.included_in Settings::Types::FONT_SCHEMES
          end
        end
      end
    end

    context "when configuring contributor roles" do
      let_it_be(:global_configuration, refind: true) { GlobalConfiguration.fetch }
      let_it_be(:vocab_1) { FactoryBot.create :controlled_vocabulary }
      let_it_be(:item_1) { FactoryBot.create :controlled_vocabulary_item, controlled_vocabulary: vocab_1 }

      let_it_be(:vocab_2) { FactoryBot.create :controlled_vocabulary }
      let_it_be(:item_2) { FactoryBot.create :controlled_vocabulary_item, controlled_vocabulary: vocab_2 }

      context "when providing valid data" do
        let_mutation_input!(:contribution_roles) do
          {
            controlled_vocabulary_id: vocab_1.to_encoded_id,
            default_item_id: item_1.to_encoded_id,
            other_item_id: item_1.to_encoded_id,
          }
        end

        let(:expected_shape) do
          gql.mutation :update_global_configuration, no_errors: true do |m|
            m.prop :global_configuration do |gc|
              gc.prop :contribution_roles do |cr|
                cr.prop :controlled_vocabulary do |cv|
                  cv[:id] = vocab_1.to_encoded_id
                end

                cr.prop :default_item do |di|
                  di[:id] = item_1.to_encoded_id
                end

                cr.prop :other_item do |oi|
                  oi[:id] = item_1.to_encoded_id
                end
              end
            end
          end
        end

        it "updates the contributor roles correctly" do
          expect_request! do |req|
            req.effect! change { global_configuration.reload_contribution_role_configuration.controlled_vocabulary_id }

            req.data! expected_shape
          end
        end
      end

      context "when providing mismatched default item" do
        let_mutation_input!(:contribution_roles) do
          {
            controlled_vocabulary_id: vocab_1.to_encoded_id,
            default_item_id: item_2.to_encoded_id,
          }
        end

        let(:expected_shape) do
          gql.mutation :update_global_configuration, no_errors: false do |m|
            m[:global_configuration] = be_blank

            m.attribute_errors do |ae|
              ae.error "contributionRoles.defaultItem", :mismatched_vocabulary_item
            end
          end
        end

        it "fails gracefully" do
          expect_request! do |req|
            req.effect! keep_the_same { global_configuration.reload_contribution_role_configuration.controlled_vocabulary_id }

            req.data! expected_shape
          end
        end
      end

      context "when providing mismatched other item" do
        let_mutation_input!(:contribution_roles) do
          {
            controlled_vocabulary_id: vocab_1.to_encoded_id,
            default_item_id: item_1.to_encoded_id,
            other_item_id: item_2.to_encoded_id,
          }
        end

        let(:expected_shape) do
          gql.mutation :update_global_configuration, no_errors: false do |m|
            m[:global_configuration] = be_blank

            m.attribute_errors do |ae|
              ae.error "contributionRoles.otherItem", :mismatched_vocabulary_item
            end
          end
        end

        it "fails gracefully" do
          expect_request! do |req|
            req.effect! keep_the_same { global_configuration.reload_contribution_role_configuration.controlled_vocabulary_id }

            req.data! expected_shape
          end
        end
      end
    end
  end

  as_an_admin_user do
    include_examples "an authorized mutation"
  end

  as_a_regular_user do
    include_examples "an unauthorized mutation"
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end
