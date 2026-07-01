# frozen_string_literal: true

module Templates
  module Digests
    module Instances
      # Upsert a single {Templates::InstanceDigest} records for a specific {TemplateInstance}.
      #
      # @see Templates::Digests::Instances::UpsertForTemplate
      class TemplateUpserter < Support::HookBased::Actor
        include Dry::Initializer[undefined: false].define -> do
          param :template_instance, Templates::Types::TemplateInstance
        end

        UNIQUE_BY = %i[template_instance_type template_instance_id].freeze

        standard_execution!

        # @return [<Hash>]
        attr_reader :tuples

        # @return [Dry::Monads::Result]
        def call
          run_callbacks :execute do
            yield prepare!
          end

          Success()
        end

        wrapped_hook! def prepare
          @tuples = []

          super
        end

        wrapped_hook! def collect
          tuple = yield template_instance.build_digest_attributes

          @tuples << tuple

          super
        end

        wrapped_hook! def upsert
          # simplecov:disable
          return super if tuples.blank?
          # simplecov:enable

          Templates::InstanceDigest.upsert_all(tuples, unique_by: UNIQUE_BY, returning: nil)

          super
        end
      end
    end
  end
end
