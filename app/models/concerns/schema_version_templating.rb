# frozen_string_literal: true

module SchemaVersionTemplating
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  included do
    has_many :hero_layout_definitions,
      class_name: "Layouts::HeroDefinition",
      inverse_of: :schema_version,
      dependent: :destroy

    has_one :root_hero_layout_definition, -> { root },
      class_name: "Layouts::HeroDefinition", inverse_of: :schema_version, dependent: :destroy
    has_many :list_item_layout_definitions,
      class_name: "Layouts::ListItemDefinition",
      inverse_of: :schema_version,
      dependent: :destroy

    has_one :root_list_item_layout_definition, -> { root },
      class_name: "Layouts::ListItemDefinition", inverse_of: :schema_version, dependent: :destroy
    has_many :main_layout_definitions,
      class_name: "Layouts::MainDefinition",
      inverse_of: :schema_version,
      dependent: :destroy

    has_one :root_main_layout_definition, -> { root },
      class_name: "Layouts::MainDefinition", inverse_of: :schema_version, dependent: :destroy
    has_many :navigation_layout_definitions,
      class_name: "Layouts::NavigationDefinition",
      inverse_of: :schema_version,
      dependent: :destroy

    has_one :root_navigation_layout_definition, -> { root },
      class_name: "Layouts::NavigationDefinition", inverse_of: :schema_version, dependent: :destroy
    has_many :metadata_layout_definitions,
      class_name: "Layouts::MetadataDefinition",
      inverse_of: :schema_version,
      dependent: :destroy

    has_one :root_metadata_layout_definition, -> { root },
      class_name: "Layouts::MetadataDefinition", inverse_of: :schema_version, dependent: :destroy
    has_many :supplementary_layout_definitions,
      class_name: "Layouts::SupplementaryDefinition",
      inverse_of: :schema_version,
      dependent: :destroy

    has_one :root_supplementary_layout_definition, -> { root },
      class_name: "Layouts::SupplementaryDefinition", inverse_of: :schema_version, dependent: :destroy

    after_create :populate_root_layouts!
  end

  # @see Schemas::Versions::PopulateRootLayouts
  # @see Schemas::Versions::RootLayoutsPopulator
  monadic_operation! def populate_root_layouts(...)
    call_operation("schemas.versions.populate_root_layouts", self, ...)
  end

  # @see #root_layout_for
  # @return [ActiveSupport:HashWithIndifferentAccess{ Layout::Types::Kind => LayoutDefinition }]
  def root_layouts
    Layout.pluck(:layout_kind).index_with { root_layout_for _1 }.with_indifferent_access
  end

  # @param [::Layouts::Types::Kind] layout_kind
  # @return [LayoutDefinition]
  def root_layout_for(layout_kind)
    assoc = :"root_#{layout_kind}_layout_definition"

    __send__(:"reload_#{assoc}") || __send__(:"build_#{assoc}")
  end

  # @param [Layouts::Types::Kind] layout_kind
  # @return [Templates::Config::Utility::AbstractLayout]
  def root_layout_config_for(layout_kind)
    # simplecov:disable
    static_record&.layout_config_for(layout_kind) || Layout.build_default_for(layout_kind)
    # simplecov:enable
  end
end
