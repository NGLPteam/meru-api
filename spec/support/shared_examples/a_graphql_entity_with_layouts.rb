# frozen_string_literal: true

RSpec.shared_examples_for "a graphql entity with layouts" do
  let_it_be(:manual_list_targets) do
    FactoryBot.create_list(:item, 2)
  end

  let(:entity) { raise "entity must be set" }

  let(:slug) { entity.system_slug }

  let(:graphql_variables) do
    { slug:, }
  end

  let(:query_name) { "get#{entity.model_name}Layouts" }
  let(:field_name) { entity.model_name.i18n_key.to_s }

  let(:query) do
    <<~GRAPHQL
    query #{query_name}($slug: Slug!) {
      entity: #{field_name}(slug: $slug) {
        ... AllLayoutsFragment
      }

      other: #{field_name}(slug: $slug) {
        ... AllLayoutsFragment
      }
    }

    fragment AllLayoutsFragment on Entity {
      layouts {
        renderedInline

        hero {
          definition: layoutDefinition {
            id
          }
          ... LayoutInstanceFragment

          template {
            definition {
              id
            }

            ... TemplateInstanceFragment

            slots {
              header {
                content
              }

              headerAside {
                content
              }

              headerSidebar {
                content
              }

              headerSummary {
                content
              }
            }
          }
        }

        listItem {
          definition: layoutDefinition {
            id
          }
          ... LayoutInstanceFragment

          template {
            definition {
              id
            }
            ... TemplateInstanceFragment
          }
        }

        navigation {
          definition: layoutDefinition {
            id
          }
          ... LayoutInstanceFragment

          template {
            definition {
              id
            }

            ... TemplateInstanceFragment
          }
        }

        metadata {
          definition: layoutDefinition {
            id
          }
          ... LayoutInstanceFragment

          template {
            definition {
              id
            }

            ... TemplateInstanceFragment
          }
        }

        supplementary {
          definition: layoutDefinition {
            id
          }
          ... LayoutInstanceFragment

          template {
            definition {
              id
            }

            ... TemplateInstanceFragment
          }
        }

        main {
          definition: layoutDefinition {
            id
          }
          ... LayoutInstanceFragment

          templates {
            __typename

            ... on TemplateInstance {
              ... TemplateInstanceFragment
            }

            ... on DescendantListTemplateInstance {
              definition {
                id
              }
              ... HasEntityListFragment
            }

            ... on LinkListTemplateInstance {
              definition {
                id
              }
              ... HasEntityListFragment
            }

            ... on OrderingTemplateInstance {
              definition {
                id
              }
              orderingPair {
                first
                last
                exists
                count
                position
                prevSibling {
                  entrySlug
                  entryTitle
                  position

                }

                nextSibling {
                  entrySlug
                  entryTitle
                  position
                }
              }
            }
          }
        }
      }

    }

    fragment AnyEntityFragment on Entity {
      __typename

      ... on Entity {
        title
        subtitle
      }
    }

    fragment HasEntityListFragment on TemplateHasEntityList {
      entityList {
        count
        empty
        entities {
          ... AnyEntityFragment
        }

        listItemLayouts {
          id

          definition: layoutDefinition {
            id
          }

          ... LayoutInstanceFragment

          template {
            ... TemplateInstanceFragment
          }

        }
      }
    }

    fragment LayoutInstanceFragment on LayoutInstance {
      allHidden
      allSlotsEmpty
      lastRenderedAt
      layoutKind
      entity {
        ... AnyEntityFragment
      }
    }

    fragment TemplateInstanceFragment on TemplateInstance {
      allSlotsEmpty
      hidden
      layoutKind
      templateKind
      lastRenderedAt
      entity {
        ... AnyEntityFragment
      }

      prevSiblings {
        ... SiblingFragment
      }

      nextSiblings {
        ... SiblingFragment
      }
    }

    fragment SiblingFragment on TemplateInstanceSibling {
      dark
      hidden
      width

      layoutKind
      templateKind
      position
    }
    GRAPHQL
  end

  let(:should_have_rendered) { false }

  let(:expected_shape) do
    gql.query do |q|
      q.prop :entity do |ent|
        ent.prop :layouts do |lyts|
          lyts[:rendered_inline] = should_have_rendered

          Layout.pluck(:layout_kind).without("main").each do |kind|
            lyts.prop kind do |lyt|
              lyt[:last_rendered_at] = be_present

              lyt.prop :template do |tpl|
                tpl[:layout_kind] = kind.upcase
                tpl[:template_kind] = kind.upcase
                tpl[:last_rendered_at] = be_present
              end
            end
          end

          lyts.prop :main do |main|
            main[:last_rendered_at] = be_present

            main[:templates] = be_present
          end
        end
      end
    end
  end

  before do
    # Get rid of layout invalidations from tests
    LayoutInvalidation.delete_all

    manual_list_targets.first.render_layouts!

    entity.manual_list_assign!(list_name: "manual", template_kind: "descendant_list", targets: manual_list_targets)
  end

  context "when no templates have been rendered" do
    let(:should_have_rendered) { true }

    it "will render the templates inline" do
      expect_request! do |req|
        req.effect! change(Layouts::MainInstance, :count).by(1)
        req.effect! execute_safely

        req.data! expected_shape
      end
    end
  end

  context "when an entity's layouts have been marked invalid" do
    let(:should_have_rendered) { true }

    before do
      entity.invalidate_layouts!
    end

    it "will process the invalid layouts inline" do
      expect_request! do |req|
        req.effect! change(LayoutInvalidation, :count).by(-1)
        req.effect! change(StaleEntity, :count).by(-1)
        req.effect! execute_safely

        req.data! expected_shape
      end
    end
  end

  context "when the templates have been rendered" do
    let(:should_have_rendered) { false }

    before do
      entity.render_layouts!
    end

    it "will fetch templates as desired" do
      expect_request! do |req|
        req.effect! keep_the_same(LayoutInvalidation, :count)
        req.effect! keep_the_same(Layouts::MainInstance, :count)
        req.effect! keep_the_same(StaleEntity, :count)
        req.effect! execute_safely

        req.data! expected_shape
      end
    end
  end
end
