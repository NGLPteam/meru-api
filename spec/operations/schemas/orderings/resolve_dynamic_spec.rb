# frozen_string_literal: true

RSpec.describe Schemas::Orderings::ResolveDynamic, type: :operation do
  let_it_be(:id) { SecureRandom.uuid }

  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let_it_be(:journal, refind: true) { FactoryBot.create :collection, schema: "nglp:journal", community: }

  let_it_be(:volume, refind: true) { FactoryBot.create :collection, schema: "nglp:journal_volume", community:, parent: journal, published: VariablePrecisionDate.parse("2025-07-09") }

  let_it_be(:issue, refind: true) { FactoryBot.create :collection, schema: "nglp:journal_issue", community:, parent: volume, published: VariablePrecisionDate.parse("2025-07-09") }

  let_it_be(:old_article, refind: true) do
    FactoryBot.create(:item, schema: "nglp:journal_article", collection: issue, published: "2025-06-01")
  end

  let_it_be(:new_article, refind: true) do
    FactoryBot.create(:item, schema: "nglp:journal_article", collection: issue, published: "2025-07-01")
  end

  let_it_be(:limit) { 5 }

  let_it_be(:entity) { journal }

  let_it_be(:definition) do
    Schemas::Orderings::Definition.new(
      order: [
        { path: "ancestors.volume.published", direction: "desc", nulls: "first" },
        { path: "ancestors.issue.published", direction: "desc", nulls: "last" },
        { path: "ancestors.issue.props.sortable_number#integer", direction: "desc" },
        { path: "entity.published", direction: "desc", },
        { path: "props.nonexisting#boolean", direction: "desc" },
        { path: "link.is_link" },
        { path: "props.some_date#variable_date" },
      ],
      filter: {
        schemas: [
          {
            namespace: "nglp",
            identifier: "journal_article"
          }
        ]
      },
      select: {
        direct: "descendants",
      }
    )
  end

  it "retrieves things in the correct order" do
    expect_calling_with(definition:, entity:, limit:, id:).to succeed.with([new_article, old_article])
  end
end
