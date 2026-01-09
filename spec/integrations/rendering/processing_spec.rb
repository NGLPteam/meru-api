# frozen_string_literal: true

RSpec.describe "Rendering Processing Integration" do
  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:journal, refind: true) { FactoryBot.create(:collection, community:, schema: "nglp:journal") }
  let_it_be(:journal_volume, refind: true) { FactoryBot.create(:collection, community:, parent: journal, schema: "nglp:journal_volume") }
  let_it_be(:journal_issue, refind: true) { FactoryBot.create(:collection, community:, parent: journal_volume, schema: "nglp:journal_issue") }

  let_it_be(:article_1, refind: true) do
    FactoryBot.create(:item, :journal_article, collection: journal_issue, issue_position: 1, published: VariablePrecisionDate.parse(Date.current - 3))
  end

  let_it_be(:article_2, refind: true) do
    FactoryBot.create(:item, :journal_article, collection: journal_issue, issue_position: 2, published: VariablePrecisionDate.parse(Date.current - 1))
  end

  def check_article!(article)
    expect do
      article.render_layouts!
    end.to execute_safely
      .and change(Templates::CachedEntityList.where(template_instance_type: "Templates::LinkListInstance"), :count).by(1)
      .and change(Templates::CachedEntityList.where(template_instance_type: "Templates::ListItemInstance"), :count).by(1)
      .and keep_the_same(Templates::CachedEntityListItem, :count)
  end

  def ordering_instance_for(record)
    record.main_layout_instance.ordering_template_instances.first!
  end

  def ordering_pair_for(ordering_template)
    ordering_template.ordering_pair
  end

  def prev_entity_for(ordering_template)
    ordering_pair_for(ordering_template).prev_sibling.try(:entity)
  end

  def next_entity_for(ordering_template)
    ordering_pair_for(ordering_template).next_sibling.try(:entity)
  end

  it "can navigate between articles" do
    check_article!(article_1)
    check_article!(article_2)

    ordering_1 = ordering_instance_for(article_1)
    ordering_2 = ordering_instance_for(article_2)

    expect(prev_entity_for(ordering_1)).to be_nil
    expect(next_entity_for(ordering_1)).to eq article_2

    expect(prev_entity_for(ordering_2)).to eq article_1
    expect(next_entity_for(ordering_2)).to be_nil
  end

  it "processes each template correctly" do
    check_article!(article_1)
    check_article!(article_2)

    expect do
      journal_issue.render_layouts!
    end.to execute_safely
      .and change(Templates::CachedEntityList, :count).by(3)
      .and change(Templates::CachedEntityListItem.where(entity: article_2), :count).by(2)
      .and change(Templates::CachedEntityListItem.where(entity: article_1), :count).by(2)

    expect do
      journal_volume.render_layouts!
    end.to execute_safely
      .and change(Templates::CachedEntityList, :count).by(3)

    expect do
      journal.render_layouts!
    end.to execute_safely
      .and change(Templates::CachedEntityList, :count).by(6)

    expect do
      community.render_layouts!
    end.to execute_safely
      .and change(Templates::CachedEntityList, :count).by(7)
  end
end
