# frozen_string_literal: true

module Templates
  # A deterministically-ordered list of contributions that can be rendered
  # within a {TemplateInstance}.
  #
  # @see Templates::Instances::FetchContributionList
  # @see Templates::Instances::ContributionListFetcher
  # @see Types::TemplateContributionListType
  # @see Types::TemplateHasContributionListType
  class ContributionList
    extend Dry::Core::Cache

    include Enumerable
    include Dry::Core::Constants
    include Dry::Core::Equalizer.new(:contributions)
    include Dry::Initializer[undefined: false].define -> do
      option :contributions, Templates::Types::Contributions, default: proc { EMPTY_ARRAY }
    end

    delegate :each, to: :valid_contributions

    alias records contributions

    # @return [Integer]
    attr_reader :count

    alias size count

    # @return [Boolean]
    attr_reader :empty

    alias empty? empty

    # @return [<Contribution>]
    attr_reader :valid_contributions

    def initialize(...)
      super

      # Future-proofing
      @valid_contributions = contributions

      @count = valid_contributions.size

      @empty = valid_contributions.blank?
    end
  end
end
