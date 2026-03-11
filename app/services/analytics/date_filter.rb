# frozen_string_literal: true

module Analytics
  class DateFilter < ::Support::FlexibleStruct
    include Dry::Core::Memoizable

    attribute? :start_date, Analytics::Types::Date.optional
    attribute? :end_date, Analytics::Types::Date.optional
    attribute? :time_zone, Analytics::Types::TimeZone

    # @param [ActiveRecord::Relation] scope
    # @param [Arel::Attribute] time_column
    # @return [ActiveRecord::Relation, nil]
    def apply_to(scope, time_column)
      scope.where(time_column.between(range)) if has_range?
    end

    def has_range?
      range.present?
    end

    def has_valid_range?
      start_time && end_time && start_time <= end_time
    end

    def has_start?
      start_date.present?
    end

    def has_end?
      end_date.present?
    end

    memoize def start_time
      start_date&.in_time_zone(time_zone)&.beginning_of_day
    end

    memoize def end_time
      end_date&.in_time_zone(time_zone)&.end_of_day
    end

    memoize def range
      if has_valid_range?
        start_time..end_time
      elsif has_start? && !has_end?
        start_time..
      elsif has_end? && !has_start?
        ..end_time
      end
    end

    def to_groupdate_options
      {}.tap do |h|
        next unless has_range?

        h[:range] = range
        h[:expand_range] = true
      end
    end

    class << self
      def for_option
        default { new }
      end
    end
  end
end
