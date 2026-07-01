# frozen_string_literal: true

module Harvesting
  module Extraction
    module LiquidTags
      # A Liquid tag that captures elements and builds a {Harvesting::Contributions::Proxy}.
      class ContributionCaptor < Harvesting::Extraction::LiquidTags::AbstractBlock
        include Dry::Effects::Handler.State(:contribution)
        include Dry::Effects::State(:capturing_contribution)
        include Dry::Effects::State(:contribution_index)

        args! :role

        # @param [Liquid::Context] context
        # @return [void]
        def render(context)
          # simplecov:disable
          raise Liquid::ContextError, "Cannot capture a contribution within a contribution" if capturing_contribution
          # simplecov:enable

          capture_contribution!(context) do
            super
          end

          return ""
        end

        private

        # @param [Liquid::Context] context
        # @return [Harvesting::Contributions::Proxy]
        def build_contribution(context)
          role_name = args.evaluate(:role, context, allow_blank: true)

          role = render_context.contributions.role_for(role_name)

          Harvesting::Contributions::Proxy.new(role_name:, role:)
        end

        # @param [Liquid::Context] context
        # @return [void]
        def capture_contribution!(context)
          self.capturing_contribution = true

          contribution = build_contribution(context)

          default_inner_position = contribution_index + 1

          with_contribution contribution do
            yield
          end

          contribution.inner_position ||= default_inner_position

          render_data[:contributions] << contribution
        ensure
          self.capturing_contribution = false
          self.contribution_index += 1
        end
      end
    end
  end
end
