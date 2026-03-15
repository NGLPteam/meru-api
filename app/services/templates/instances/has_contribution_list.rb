# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::ContributionList
    # @see Templates::Instances::FetchContributionList
    # @see Templates::Instances::ContributionListFetcher
    # @see Templates::Definitions::HasContributionList
    # @see Types::TemplateContributionListType
    # @see Types::TemplateHasContributionListType
    module HasContributionList
      extend ActiveSupport::Concern
      extend DefinesMonadicOperation

      # @return [Templates::ContributionList]
      def contribution_list = fetch_contribution_list!

      monadic_operation! def fetch_contribution_list
        call_operation("templates.instances.fetch_contribution_list", self)
      end
    end
  end
end
