# frozen_string_literal: true

module Templates
  module Slots
    # This service caches built liquid environments for specific
    # kinds in memory, since it won't change across runtimes.
    #
    # @see Templates::Slots::BuildEnvironment
    class EnvironmentBuilder < Support::HookBased::Actor
      extend Dry::Core::Cache

      include Dry::Initializer[undefined: false].define -> do
        option :kind, Types::SlotKind, default: proc { "block" }
      end

      standard_execution!

      # @return [Liquid::Environment]
      attr_reader :environment

      # @return [Dry::Monads::Success(Liquid::Environment)]
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
        fetch_or_store :env, kind do
          Liquid::Environment.build(error_mode: :strict) do |env|
            case kind
            in "block"
              configure_block!(env)
            in "inline"
              configure_inline!(env)
            else
              # :nocov:
              raise "Unhandled Slot Kind"
              # :nocov:
            end
          end
        end
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def configure_block!(env)
        env.register_tag "asset", Templates::Tags::Blocks::Asset
        env.register_tag "pdfviewer", Templates::Tags::Flat::PDFViewer

        configure_common! env

        register_metadata! env
        register_sidebar! env
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def configure_common!(env)
        env.register_tag "copylink", Templates::Tags::Blocks::CopyLink
        env.register_tag "entitylink", Templates::Tags::Blocks::EntityLink
        env.register_tag "ifpresent", ::LiquidExt::Tags::IfPresent
        env.register_tag "ifinteger", ::LiquidExt::Tags::IfInteger

        env.register_filter LiquidExt::CommonFilters
        env.register_filter Templates::Filters::CommonFilters

        register_dot_list! env
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def configure_inline!(env)
        configure_common! env
      end

      def register_dot_list!(env)
        env.register_tag "dotlist", Templates::Tags::Blocks::DotList
        env.register_tag "dotitem", Templates::Tags::Blocks::DotItem
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def register_metadata!(env)
        env.register_tag "mdlist", Templates::Tags::Blocks::MetadataList
        env.register_tag "mditem", Templates::Tags::Blocks::MetadataItem
        env.register_tag "mdlabel", Templates::Tags::Blocks::MetadataLabel
        env.register_tag "mdpair", Templates::Tags::Blocks::MetadataPair
        env.register_tag "mdvalue", Templates::Tags::Blocks::MetadataValue
      end

      # @param [Liquid::Environment] env
      # @return [void]
      def register_sidebar!(env)
        env.register_tag "sblist", Templates::Tags::Blocks::SidebarList
        env.register_tag "sbitem", Templates::Tags::Blocks::SidebarItem
      end
    end
  end
end
