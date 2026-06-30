# frozen_string_literal: true

# A test concern for dealing with locking scopes for GraphQL resolvers.
#
# In the future, we'll test resolvers directly so that this is easier.
module ScopeLocking
  extend ActiveSupport::Concern

  module ClassMethods
    def lock_to!(*records)
      records.flatten!

      @record_ids, original = records.map(&:id), record_ids

      yield
    ensure
      @record_ids = original
    end

    # @return [ActiveRecord::Relation]
    def maybe_locked
      if record_ids.any?
        where(id: record_ids)
      else
        all
      end
    end

    def record_ids
      @record_ids ||= Dry::Core::Constants::EMPTY_ARRAY
    end
  end
end
