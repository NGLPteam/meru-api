# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::ContributorMerge
    # @see Mutations::Operations::ContributorMerge
    class ContributorMerge < MutationOperations::Contract
      json do
        required(:source).value(:contributor)
        required(:target).value(:contributor)
      end

      rule :source do
        value.check_merge_to(values[:target]) do |m|
          m.success do |value|
            base.failure(:contributor_merge_in_progress) if value == :existing
          end

          m.failure do |key, *_|
            case key
            in :same_contributor
              base.failure(:contributor_merge_same_contributor)
            in :source_merging
              base.failure(:contributor_merge_source_merging)
            in :target_merging
              base.failure(:contributor_merge_target_merging)
            else
              # simplecov:disable
              raise "Unexpected validation error key: #{key.inspect}"
              # simplecov:enable
            end
          end
        end
      end
    end
  end
end
