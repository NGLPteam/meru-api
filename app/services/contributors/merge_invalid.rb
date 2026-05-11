# frozen_string_literal: true

module Contributors
  # An error raised when the merge process cannot be performed
  # owing to some incongruence.
  class MergeInvalid < StandardError; end
end
