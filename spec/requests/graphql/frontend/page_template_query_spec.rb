# frozen_string_literal: true

RSpec.describe "pageTemplateQuery", type: :request do
  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:journal, refind: true) { FactoryBot.create(:collection, community:, schema: "nglp:journal") }
  let_it_be(:journal_volume, refind: true) { FactoryBot.create(:collection, community:, parent: journal, schema: "nglp:journal_volume") }
  let_it_be(:journal_issue, refind: true) { FactoryBot.create(:collection, community:, parent: journal_volume, schema: "nglp:journal_issue") }
  let_it_be(:article_1, refind: true) { FactoryBot.create(:item, collection: journal_issue, schema: "nglp:journal_article", published: VariablePrecisionDate.parse(Date.current - 3)) }
  let_it_be(:article_2, refind: true) { FactoryBot.create(:item, collection: journal_issue, schema: "nglp:journal_article", published: VariablePrecisionDate.parse(Date.current - 1)) }

  let_it_be(:rendered) do
    [article_1, article_2, journal_issue, journal_volume, journal, community].each do |entity|
      entity.render_layouts!
    end
  end

  let(:query) do
    named_query("pageTemplateQuery")
  end

  let(:slug) { community.system_slug }

  let(:graphql_variables) do
    {
      slug:,
    }
  end

  let(:expected_shape) do
    gql.query do |q|
      q.prop :community do |comm|
        comm[:id] = community.to_encoded_id

        comm.prop :layouts do |layouts|
          layouts.prop :main do |main|
            main[:id] = be_present
          end
        end
      end
    end
  end

  it "renders details for the community's main layout" do
    expect_request! do |req|
      req.data! expected_shape
    end
  end
end
