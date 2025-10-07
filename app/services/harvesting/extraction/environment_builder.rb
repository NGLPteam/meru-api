# frozen_string_literal: true

module Harvesting
  module Extraction
    # @see Harvesting::Extraction::BuildEnvironment
    class EnvironmentBuilder < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        option :captures_contributions, Harvesting::Extraction::Types::Bool, default: proc { false }
        option :captures_metadata_mappings, Harvesting::Extraction::Types::Bool, default: proc { false }

        option :property_type, Harvesting::Extraction::Types::SchemaPropertyType.optional, optional: true
      end

      standard_execution!

      # @return [Liquid::Environment]
      attr_reader :environment

      # @return [Dry::Monads::Result]
      def call
        run_callbacks :execute do
          yield build!
        end

        Success environment
      end

      wrapped_hook! def build
        @environment = build_liquid_environment

        super
      end

      private

      # @return [Liquid::Environment]
      def build_liquid_environment
        Liquid::Environment.build(error_mode: :strict) do |env|
          env.register_filter Harvesting::Extraction::CommonFilters

          env.file_system = Harvesting::Extraction::FileSystem.new

          configure_common_tags!(env)

          if captures_contributions
            configure_contribution_capture!(env)
          elsif captures_metadata_mappings
            configure_metadata_mappings_capture!(env)
          else
            configure_for_property_type!(env)
          end
        end
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def configure_common_tags!(env)
        env.register_tag "ifpresent", ::LiquidExt::Tags::IfPresent
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def configure_contribution_capture!(env)
        contribution_capture_add_base_tags!(env)
        contribution_capture_add_contribution_attributes!(env)
        contribution_capture_add_contributor_attributes!(env)
        contribution_capture_add_organization_properties!(env)
        contribution_capture_add_person_properties!(env)
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def configure_metadata_mappings_capture!(env)
        env.register_tag "identifier", Harvesting::Extraction::LiquidTags::MetadataMappings::IdentifierTag
        env.register_tag "relation", Harvesting::Extraction::LiquidTags::MetadataMappings::RelationTag
        env.register_tag "title", Harvesting::Extraction::LiquidTags::MetadataMappings::TitleTag
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def configure_for_property_type!(env)
        case property_type
        when "tags"
          env.register_tag "tag", Harvesting::Extraction::LiquidTags::TagCaptor
        end
      end

      # @!group Contribution Capture DSL

      # @param [Liquid::Environment] env
      # @return [void]
      def contribution_capture_add_base_tags!(env)
        env.register_tag "contribution", Harvesting::Extraction::LiquidTags::ContributionCaptor
        env.register_tag "organization", Harvesting::Extraction::LiquidTags::OrganizationContributorCaptor
        env.register_tag "person", Harvesting::Extraction::LiquidTags::PersonContributorCaptor
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def contribution_capture_add_contribution_attributes!(env)
        env.register_tag "inner_position", Harvesting::Extraction::LiquidTags::Contributions::InnerPositionTag
        env.register_tag "outer_position", Harvesting::Extraction::LiquidTags::Contributions::OuterPositionTag
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def contribution_capture_add_contributor_attributes!(env)
        env.register_tag "bio", Harvesting::Extraction::LiquidTags::Contributors::BioTag
        env.register_tag "email", Harvesting::Extraction::LiquidTags::Contributors::EmailTag
        env.register_tag "identifier", Harvesting::Extraction::LiquidTags::Contributors::IdentifierTag
        env.register_tag "orcid", Harvesting::Extraction::LiquidTags::Contributors::ORCIDTag
        env.register_tag "prefix", Harvesting::Extraction::LiquidTags::Contributors::PrefixTag
        env.register_tag "suffix", Harvesting::Extraction::LiquidTags::Contributors::SuffixTag
        env.register_tag "contributor_url", Harvesting::Extraction::LiquidTags::Contributors::URLTag
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def contribution_capture_add_organization_properties!(env)
        env.register_tag "legal_name", Harvesting::Extraction::LiquidTags::Contributors::LegalNameTag
        env.register_tag "location", Harvesting::Extraction::LiquidTags::Contributors::LocationTag
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def contribution_capture_add_person_properties!(env)
        env.register_tag "affiliation", Harvesting::Extraction::LiquidTags::Contributors::AffiliationTag
        env.register_tag "appellation", Harvesting::Extraction::LiquidTags::Contributors::AppellationTag
        env.register_tag "family_name", Harvesting::Extraction::LiquidTags::Contributors::FamilyNameTag
        env.register_tag "given_name", Harvesting::Extraction::LiquidTags::Contributors::GivenNameTag
        env.register_tag "title", Harvesting::Extraction::LiquidTags::Contributors::TitleTag
      end

      # @!endgroup
    end
  end
end
