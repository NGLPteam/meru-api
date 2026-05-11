# frozen_string_literal: true

module Contributors
  # @see Contributors::ContributionsCopier
  class CopyContributions < Support::SimpleServiceOperation
    service_klass Contributors::ContributionsCopier
  end
end
