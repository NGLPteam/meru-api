# frozen_string_literal: true

module Templates
  # A digest of all {TemplateInstance} records, uninioned into a single table for introspection.
  #
  # The original tables are more optimized and are the source of truth.
  class InstanceDigest < ApplicationRecord
    include HasEphemeralSystemSlug
    include TimestampScopes

    belongs_to :template_instance, polymorphic: true, inverse_of: :instance_digest
    belongs_to :template_definition, polymorphic: true, inverse_of: :instance_digests
    belongs_to :layout_instance, polymorphic: true, inverse_of: :template_instance_digests
    belongs_to :layout_definition, polymorphic: true, inverse_of: :template_instance_digests
    belongs_to :entity, polymorphic: true, inverse_of: :template_instance_digests

    attribute :config, Templates::Digests::Instances::Config.to_type
    attribute :slots, Templates::Digests::Instances::Slots.to_type

    class << self
      # @return [Hash]
      def layout_instance_stats
        all_hidden = arel_all_count(arel_table[:hidden].eq(true)).as("all_hidden")
        all_slots_empty = arel_all_count(arel_table[:all_slots_empty].eq(true)).as("all_slots_empty")

        connection.select_one(reselect(all_hidden, all_slots_empty).to_sql).symbolize_keys
      end

      # @param [Arel::Nodes::Node] condition
      # @return [Arel::Nodes::Grouping]
      def arel_all_count(condition)
        count = Arel::Nodes::Count.new([Arel.star])

        hidden_count = count.filter(condition)

        arel_grouping(hidden_count.eq(count))
      end
    end
  end
end
