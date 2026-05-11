# frozen_string_literal: true

module Contributors
  # @see Contributors::MergeStarter
  class MergeTo < Support::SimpleServiceOperation
    service_klass Contributors::MergeStarter
  end
end
