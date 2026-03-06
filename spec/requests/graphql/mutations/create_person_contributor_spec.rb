# frozen_string_literal: true

RSpec.describe Mutations::CreatePersonContributor, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation createPersonContributor($input: CreatePersonContributorInput!) {
    createPersonContributor(input: $input) {
      contributor {
        kind
        id
        name
        orcid
        url
        givenName
        familyName
        title
        affiliation

        links {
          title
          url
        }

        contributionCount
        collectionContributionCount
        itemContributionCount
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_mutation_input!(:url) { Faker::Internet.url }
  let_mutation_input!(:bio) { Faker::Lorem.paragraphs(number: 4).join("\n") }

  let_mutation_input!(:links) do
    2.times.map do
      { title: Faker::Lorem.sentence, url: Faker::Internet.url }
    end
  end

  # person-specific properties
  let_mutation_input!(:given_name) { Faker::Name.first_name }
  let_mutation_input!(:family_name) { Faker::Name.last_name }
  let_mutation_input!(:title) { Faker::Name.prefix }
  let_mutation_input!(:affiliation) { Faker::Company.name }
  let_mutation_input!(:orcid) { nil }

  shared_examples_for "a successful creation" do
    let!(:expected_shape) do
      gql.mutation :create_person_contributor do |m|
        m.prop :contributor do |c|
          c[:kind] = "person"
          c[:id] = be_present
          c[:url] = url.presence
          c[:orcid] = orcid.presence
          c[:given_name] = given_name
          c[:family_name] = family_name
          c[:title] = title
          c[:affiliation] = affiliation

          c[:links] = links
          c[:contribution_count] = 0
          c[:collection_contribution_count] = 0
          c[:item_contribution_count] = 0
        end
      end
    end

    it "creates a person contributor", :aggregate_failures do
      expect_request! do |req|
        req.effect! change(Contributor, :count).by(1)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "a failed creation" do
    it "does not create the contributor" do
      expect_request! do |req|
        req.effect! keep_the_same Contributor, :count

        req.data! expected_shape
      end
    end
  end

  as_an_admin_user do
    context "with valid inputs" do
      it_behaves_like "a successful creation"
    end

    context "with an invalid link" do
      let(:links) do
        [{ title: "Some Link", url: "bad://link" }]
      end

      let!(:expected_shape) do
        gql.mutation :create_person_contributor, no_errors: false do |m|
          m[:contributor] = nil

          m.attribute_errors do |eb|
            eb.error "links.0.url", :must_be_url
          end
        end
      end

      it_behaves_like "a failed creation"
    end

    context "with orcid set to an empty string" do
      let_mutation_input!(:orcid) { "" }

      include_examples "a successful creation"
    end

    context "with an already existing ORCID" do
      let(:orcid_value) { Testing::ORCID.random }

      let_mutation_input!(:orcid) { orcid_value }

      let!(:existing_contributor) { FactoryBot.create :contributor, :person, orcid: orcid_value }

      let!(:expected_shape) do
        gql.mutation(:create_person_contributor, no_errors: false) do |m|
          m[:contributor] = nil

          m.attribute_errors do |eb|
            eb.error :orcid, :must_be_unique_orcid
          end
        end
      end

      it_behaves_like "a failed creation"
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :create_person_contributor
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely

        req.unauthorized!

        req.data! expected_shape
      end
    end
  end

  as_a_regular_user do
    include_examples "an unauthorized mutation"
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end
