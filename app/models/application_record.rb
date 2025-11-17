# frozen_string_literal: true

# @abstract The base model for Meru-API.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend ArelHelpers
  extend DefinesMonadicOperation
  include AssociationHelpers
  include CountFromSubquery
  include DistinctOnOrderValues
  include GraphQLModelSupport
  include LazyOrdering
  include LimitToOne
  include ModelMutationSupport
  include PostgresEnums
  include StoreModelIntrospection
  include WhereMatches
  include WithAdvisoryLock::Concern

  def call_operation(name, ...)
    MeruAPI::Container[name].call(...)
  end

  # Quote the model's primary key if it is persisted and a single string.
  #
  # @return [String, nil]
  def quoted_id
    self.class.connection.quote id if persisted? && id.kind_of?(String)
  end

  class << self
    # @note Only in tests
    def default_factory
      model_name.i18n_key
    end

    def arel_text_contains(field, value)
      arel_table[field].matches("%#{escape_ilike_needle(value)}%")
    end

    def escape_ilike_needle(needle)
      needle.gsub("%", "\\%").gsub("_", "\\_")
    end

    # @param [<ApplicationRecord>] records
    # @return [ActiveRecord::Relation<ApplicationRecord>]
    def limited_to(*records)
      return all if records.flatten.blank?

      id = records.flatten.map do |record|
        case record
        when self then record.id
        when ::Support::GlobalTypes::UUID then record
        end
      end.compact.uniq

      id.blank? ? none : where(id:)
    end

    def quoted_ids
      ids.map { |id| connection.quote id }
    end

    def sample(num = nil)
      randomized = reorder(Arel.sql("RANDOM()"))

      if num.is_a?(Integer) && num >= 1
        randomized.limit(num)
      else
        randomized.first
      end
    end

    alias scoped_sample sample
  end
end
