# frozen_string_literal: true

RSpec.describe "Query.contributor", type: :request, disable_ordering_refresh: true do
  let!(:query) do
    <<~GRAPHQL
    query getContributor($orgSlug: Slug!, $personSlug: Slug!) {
      organization: contributor(slug: $orgSlug) {
        ... AnyContributorDetailsFragment
      }

      person: contributor(slug: $personSlug) {
        ... AnyContributorDetailsFragment
      }
    }

    fragment AnyContributorDetailsFragment on Contributor {
      ... on OrganizationContributor {
        slug

        ... ContributorDetailsFragment
      }

      ... on PersonContributor {
        slug

        ... ContributorDetailsFragment
      }
    }

    fragment ContributorDetailsFragment on Contributor {
      __typename

      kind

      attributions {
        nodes {
          ... on ContributorAttribution {
            entitySlug
            kind
            published {
              precision
              value
            }
            publishedOn

            roles {
              label
            }

            title
          }

          ... on ContributorCollectionAttribution {
            collection {
              id
            }
          }

          ... on ContributorItemAttribution {
            item {
              id
            }
          }
        }
      }

      collectionContributions {
        nodes {
          id
        }
      }

      itemContributions {
        nodes { id }
      }
    }
    GRAPHQL
  end

  as_an_admin_user do
    context "with a valid slug" do
      let(:graphql_variables) do
        {
          org_slug: org_contributor.system_slug,
          person_slug: person_contributor.system_slug,
        }
      end

      let_it_be(:org_contributor, refind: true) do
        FactoryBot.create :contributor, :organization
      end

      let_it_be(:person_contributor, refind: true) do
        FactoryBot.create :contributor, :person
      end

      let(:contributors) { [org_contributor, person_contributor] }

      let!(:expected_shape) do
        a_single_node = { nodes: [{ id: a_kind_of(String) } ] }

        gql.query do |q|
          q.prop :organization do |org|
            org.typename("OrganizationContributor")

            org[:slug] = org_contributor.system_slug
            org[:collection_contributions] = a_single_node
            org[:item_contributions] = a_single_node
          end

          q.prop :person do |org|
            org.typename("PersonContributor")

            org[:slug] = person_contributor.system_slug
            org[:collection_contributions] = a_single_node
            org[:item_contributions] = a_single_node
          end
        end
      end

      before do
        contributors.map do |contributor|
          FactoryBot.create(:collection_contribution, contributor:)
          FactoryBot.create(:item_contribution, contributor:)
        end
      end

      it "has the expected shape" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    context "with an invalid slug" do
      let!(:graphql_variables) { { org_slug: random_slug, person_slug: random_slug } }

      let!(:expected_shape) do
        gql.query do |q|
          q[:organization] = be_blank
          q[:person] = be_blank
        end
      end

      it "returns nil" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    context "when ordering contributions" do
      let_it_be(:contributor, refind: true) { FactoryBot.create :contributor, :person }

      let!(:slug) { contributor.system_slug }
      let!(:order) { "RECENT" }

      let!(:graphql_variables) { { slug:, order: } }

      let!(:query) do
        <<~GRAPHQL
        query getContributor($slug: Slug!, $order: ContributionOrder!) {
          contributor(slug: $slug) {
            ... on Contributor {
              collectionContributions(order: $order) {
                edges {
                  node {
                    ... ContributionFragment
                  }
                }

                pageInfo { totalCount }
              }

              itemContributions(order: $order) {
                edges {
                  node {
                    ... ContributionFragment
                  }
                }

                pageInfo { totalCount }
              }
            }
          }
        }

        fragment ContributionFragment on Node {
          id
        }
        GRAPHQL
      end

      let(:contribution_factory) { :"#{target_factory}_contribution" }
      let(:association_key) { contribution_factory.to_s.pluralize.to_sym }

      let(:target_factory) { raise "must set" }

      let!(:contribution_a3) do
        Timecop.freeze(3.days.ago) do
          FactoryBot.create contribution_factory, contributor:, target_factory => FactoryBot.create(target_factory, title: "AA")
        end
      end

      let!(:contribution_m1) do
        Timecop.freeze(1.day.ago) do
          FactoryBot.create contribution_factory, contributor:, target_factory => FactoryBot.create(target_factory, title: "MM")
        end
      end

      let!(:contribution_z2) do
        Timecop.freeze(2.days.ago) do
          FactoryBot.create contribution_factory, contributor:, target_factory => FactoryBot.create(target_factory, title: "ZZ")
        end
      end

      let!(:keyed_models) do
        {
          a3: to_rep(contribution_a3),
          m1: to_rep(contribution_m1),
          z2: to_rep(contribution_z2),
        }
      end

      def to_rep(model)
        {
          id: model.to_encoded_id,
        }
      end

      shared_examples_for "an ordered list of contributions" do |order_value, *keys|
        let!(:order) { order_value }

        let!(:expected_shape) do
          {
            contributor: {
              association_key => {
                edges: keys.map { |k| { node: keyed_models.fetch(k) } },
                page_info: { total_count: keyed_models.size },
              },
            }
          }
        end

        it "returns contributions in the expected order" do
          expect_request! do |req|
            req.data! expected_shape
          end
        end
      end

      shared_examples_for "ordered contributions" do
        {
          "RECENT" => %i[m1 z2 a3],
          "OLDEST" => %i[a3 z2 m1],
          "TARGET_TITLE_ASCENDING" => %i[a3 m1 z2],
          "TARGET_TITLE_DESCENDING" => %i[z2 m1 a3],
        }.each do |order, keys|
          context "when ordered by #{order}" do
            include_examples "an ordered list of contributions", order, *keys
          end
        end
      end

      describe "collectionContributions" do
        let(:target_factory) { :collection }

        include_examples "ordered contributions"
      end

      describe "itemContributions" do
        let(:target_factory) { :item }

        include_examples "ordered contributions"
      end
    end
  end
end
