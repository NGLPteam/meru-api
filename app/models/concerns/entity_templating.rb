# frozen_string_literal: true

# @see ::Types::EntityLayoutsType
module EntityTemplating
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  include EntityTemplatingSupport
  include ModelMutationSupport

  included do
    has_many :layout_definition_hierarchies, as: :entity, inverse_of: :entity, dependent: :delete_all

    has_many :layout_instance_digests, as: :entity, inverse_of: :entity, class_name: "Layouts::InstanceDigest", dependent: :delete_all

    has_many :layout_invalidations, as: :entity, inverse_of: :entity, dependent: :delete_all

    has_one_readonly :stale_entity, as: :entity, inverse_of: :entity

    has_many :rendering_entity_logs, as: :entity, inverse_of: :entity, class_name: "Rendering::EntityLog", dependent: :delete_all

    has_many :rendering_layout_logs, as: :entity, inverse_of: :entity, class_name: "Rendering::LayoutLog", dependent: :delete_all

    has_many :rendering_template_logs, as: :entity, inverse_of: :entity, class_name: "Rendering::TemplateLog", dependent: :delete_all

    has_many :template_instance_digests, as: :entity, inverse_of: :entity, class_name: "Templates::InstanceDigest", dependent: :delete_all

    has_many :hero_layout_definitions,
      class_name: "Layouts::HeroDefinition",
      as: :entity,
      dependent: :destroy

    has_one :hero_layout_instance,
      class_name: "Layouts::HeroInstance",
      as: :entity,
      inverse_of: :entity,
      dependent: :destroy

    has_many :list_item_layout_definitions,
      class_name: "Layouts::ListItemDefinition",
      as: :entity,
      dependent: :destroy

    has_one :list_item_layout_instance,
      class_name: "Layouts::ListItemInstance",
      as: :entity,
      inverse_of: :entity,
      dependent: :destroy

    has_many :main_layout_definitions,
      class_name: "Layouts::MainDefinition",
      as: :entity,
      dependent: :destroy

    has_one :main_layout_instance,
      class_name: "Layouts::MainInstance",
      as: :entity,
      inverse_of: :entity,
      dependent: :destroy

    has_many :navigation_layout_definitions,
      class_name: "Layouts::NavigationDefinition",
      as: :entity,
      dependent: :destroy

    has_one :navigation_layout_instance,
      class_name: "Layouts::NavigationInstance",
      as: :entity,
      inverse_of: :entity,
      dependent: :destroy

    has_many :metadata_layout_definitions,
      class_name: "Layouts::MetadataDefinition",
      as: :entity,
      dependent: :destroy

    has_one :metadata_layout_instance,
      class_name: "Layouts::MetadataInstance",
      as: :entity,
      inverse_of: :entity,
      dependent: :destroy

    has_many :supplementary_layout_definitions,
      class_name: "Layouts::SupplementaryDefinition",
      as: :entity,
      dependent: :destroy

    has_one :supplementary_layout_instance,
      class_name: "Layouts::SupplementaryInstance",
      as: :entity,
      inverse_of: :entity,
      dependent: :destroy

    after_save :invalidate_layouts!, unless: :in_graphql_mutation?
    after_save :invalidate_related_layouts!, unless: :in_graphql_mutation?
  end

  # @see #invalidate_layouts
  # @see #invalidate_related_layouts
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def invalidate_all_layouts
    invalidate_layouts.bind do
      invalidate_related_layouts
    end
  end

  # @see Entities::InvalidateLayouts
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def invalidate_layouts
    call_operation("entities.invalidate_layouts", self)
  end

  # @see Entities::InvalidateRelatedLayouts
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def invalidate_related_layouts
    call_operation("entities.invalidate_related_layouts", self)
  end

  # @see Entities::RenderLayout
  # @see Entities::LayoutRenderer
  # @param [Layouts::Types::Kind] layout_kind
  # @return [Dry::Monads::Success(HierarchicalEntity)]
  monadic_matcher! def render_layout(layout_kind, generation: nil)
    call_operation("entities.render_layout", self, generation:, layout_kind:)
  end

  # @see Entities::RenderLayouts
  # @see Entities::LayoutsRenderer
  # @return [Dry::Monads::Success(HierarchicalEntity)]
  monadic_matcher! def render_layouts
    call_operation("entities.render_layouts", self)
  end
end
