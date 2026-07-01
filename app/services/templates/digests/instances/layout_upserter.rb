# frozen_string_literal: true

module Templates
  module Digests
    module Instances
      # Upsert {Templates::InstanceDigest} records for all {TemplateInstance}s within a {LayoutInstance}.
      #
      # @see Templates::Digests::Instances::UpsertForLayout
      class LayoutUpserter < Support::HookBased::Actor
        include Dry::Initializer[undefined: false].define -> do
          param :layout_instance, Templates::Types::LayoutInstance
        end

        UNIQUE_BY = %i[template_instance_type template_instance_id].freeze

        delegate :generation, :template_instances, :template_instance_digests, to: :layout_instance

        standard_execution!

        # @return [<Hash>]
        attr_reader :tuples

        # @return [Dry::Monads::Success(void)]
        def call
          run_callbacks :execute do
            yield prepare!

            yield collect!

            yield upsert!

            yield prune!
          end

          Success()
        end

        wrapped_hook! def prepare
          @tuples = []

          super
        end

        wrapped_hook! def collect
          template_instances.each do |instance|
            tuple = yield instance.build_digest_attributes

            @tuples << tuple
          end

          super
        end

        wrapped_hook! def upsert
          # simplecov:disable
          return super if tuples.blank?
          # simplecov:enable

          Templates::InstanceDigest.upsert_all(tuples, unique_by: UNIQUE_BY, returning: nil)

          super
        end

        wrapped_hook! def prune
          template_instance_digests.where.not(generation:).delete_all

          super
        end
      end
    end
  end
end
