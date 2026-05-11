# frozen_string_literal: true

module Contributors
  # An error raised when some part of the merge process failed
  # and should be investigated.
  class MergeFailed < StandardError; end
end
