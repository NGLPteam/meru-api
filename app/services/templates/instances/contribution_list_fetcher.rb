# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::FetchContributionList
    class ContributionListFetcher < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :template_instance, Templates::Types::TemplateInstance
      end

      delegate :entity, :template_definition, to: :template_instance

      delegate :filter, :limit, to: :template_definition

      standard_execution!

      # @return [ActiveRecord::Relation<Contribution>]
      attr_reader :base_scope

      # @return [<Contribution>]
      attr_reader :contributions

      # @return [Dry::Monads::Success(Templates::ContributionList)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield resolve!
        end

        contribution_list = Templates::ContributionList.new(contributions:)

        Success contribution_list
      end

      wrapped_hook! def prepare
        @base_scope = entity.contributions.all

        @contributions = EMPTY_ARRAY

        super
      end

      wrapped_hook! def resolve
        @contributions = @base_scope.for_template_list(filter:, limit:).to_a

        super
      end
    end
  end
end
