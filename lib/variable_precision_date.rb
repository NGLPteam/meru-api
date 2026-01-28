# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/core/memoizable"

# A value object that represents a date whose precision is not necessarily exact,
# i.e. it can represent a specific month in a year or an entire calendar year.
#
# Published content often does not have exact dates associated with it, necessitating
# an approach that allows us to record that ambiguity.
#
# In the database, variable precision dates are backed by a specific composite type,
# `variable_precision_date`, which is handled by {GlobalTypes::VariablePrecisionDate}.
class VariablePrecisionDate
  include Dry::Core::Equalizer.new(:value, :precision)
  include Dry::Core::Memoizable

  # The level of precision a date guarantees.
  #
  # Can be `:none`, `:year`, `:month, or `:day`, in order of increasing precision.
  #
  # See {VariablePrecisionDate#value} for a breakdown of how precision affects the normalized date.
  Precision = Dry::Types["coercible.symbol"].enum(:none, :year, :month, :day).fallback(:none).constructor do |value|
    case value
    when String then value.downcase
    else
      value
    end
  end

  # A dry.rb hash schema for matching a value and a precision
  # provided through various APIs, namely from GraphQL, and
  # parsing it into a {VariablePrecisionDate}.
  HashSchema = Dry::Types["hash"].schema(
    value: Dry::Types["json.date"],
    precision: Precision,
  ).with_key_transform(&:to_sym)

  private_constant :HashSchema

  # A regular expression to match both unquoted and quoted precisions within
  # the {.SQL_REPRESENTATION SQL representation} of a variable precision date.
  SQL_PRECISIONS = %w[none year month day].flat_map do |precision|
    [precision, precision.to_s.inspect]
  end.then { |precisions| Regexp.union precisions }

  private_constant :SQL_PRECISIONS

  # A regular expression for matching an encoded variable precision date in the database.
  SQL_REPRESENTATION = /\A\([^,]*,(?:#{SQL_PRECISIONS})?\)\z/

  private_constant :SQL_REPRESENTATION

  ISO_8601 = /\A\d{4}\D\d{2}\D\d{2}\z/

  YEAR_INT = ->(o) { o.kind_of?(Integer) && o.to_s.length == 4 }

  YEAR_ONLY = /\A(?<year>\d{4})\z/

  YEAR_MONTH = /\A(?<year>\d{4})\D?(?<month>\d{2})\z/

  XMLSCHEMA_TIME_FORMAT = /\A\s*
  (-?\d+)-(\d\d)-(\d\d)
  T
  (\d\d):(\d\d):(\d\d)
  (\.\d+)?
  (Z|[+-]\d\d(?::?\d\d)?)?
  \s*\z/ix

  # @api private
  # An array of `===`-comparable objects that represent something that can be parsed into a {VariablePrecisionDate}.
  #
  # @see VariablePrecisionDate.parse
  PARSEABLE = [
    self.class,
    ::Date,
    ::DateTime,
    Dry::Types["json.date"],
    HashSchema,
    SQL_REPRESENTATION,
    ::Time,
    XMLSCHEMA_TIME_FORMAT,
    YEAR_INT,
    YEAR_MONTH,
    YEAR_ONLY,
  ].freeze

  # An encoder to generate a proper composite record for SQL.
  #
  # @see #to_sql
  # @see DECODER
  ENCODER = PG::TextEncoder::Record.new

  private_constant :ENCODER

  # A decoder to parse a `variable_precision_date` from SQL.
  #
  # @see .parse_sql
  # @see ENCODER
  DECODER = PG::TextDecoder::Record.new

  private_constant :DECODER

  # @!parse ruby
  #   # @param [Date, String, nil] raw_value An actual ruby `Date`, or JSON/ISO8601-encoded date value
  #   # @param [:none, :year, :month, :day] raw_precision (@see VariablePrecisionDate::Precision)
  #   def initialize(raw_value = nil, raw_precision = :none)
  #   end
  #
  #   # @!attribute [r] raw_value
  #   # The value provided to the initializer. It will be normalized in {#value}.
  #   # @api private
  #   # @return [Date, nil]
  #   attr_reader :raw_value
  #
  #   # @!attribute [r] raw_precision
  #   # The precision provided to the initializer. It will be normalized in {#raw_precision}
  #   # @api private
  #   # @return [:none, :year, :month, :day]
  #   attr_reader :raw_precision

  include Dry::Initializer[undefined: false].define -> do
    param :raw_value, Dry::Types["json.date"].optional, default: proc {}, reader: :private
    param :raw_precision, Precision, default: proc { :none }, reader: :private
  end

  # @!attribute [r] value
  # Normalize {#raw_value}
  # - For `:none`-valued dates, this will be `nil` as the date is unknown or unspecified.
  # - For `:year`-valued dates, this can only be guaranteed for the associated year.
  #   {#raw_value} will be normalized to January 1 of that year.
  # - For `:month`-valued dates, this can only be guaranteed for the associated year and month.
  #   {#raw_value} will be normalized to the first of the month.
  # - For `:day`-valued dates, the exact value can be trusted.
  # @return [Date, nil]
  memoize def value
    case precision
    when :day then raw_value
    when :month then raw_value.at_beginning_of_month
    when :year then raw_value.at_beginning_of_year
    end
  end

  # @!attribute [r] precision
  # Normalized from {#raw_precision}. If {#raw_value} was blank, this is `:none` regardless of what was passed.
  # @see VariablePrecisionDate::Precision
  # @return [:none, :year, :month, :day]
  memoize def precision
    raw_value.blank? ? :none : raw_precision
  end

  def day?
    precision == :day
  end

  alias exact? day?

  def inexact?
    !exact?
  end

  # @return [String, nil]
  def iso8601
    value&.iso8601
  end

  def month?
    precision == :month
  end

  def none?
    precision == :none
  end

  def year?
    precision == :year
  end

  # @return [Date, nil]
  def to_date
    value unless none?
  end

  def to_liquid
    self
  end

  def to_s
    case precision
    in :day then iso8601
    in :month then value.strftime("%Y-%m")
    in :year then value.strftime("%Y")
    else
      ""
    end
  end

  # Encode a variable precision date into its SQL representation.
  # @return [String] the SQL representation of this object.
  def to_sql
    ENCODER.encode([value, precision])
  end

  # @see #to_sql
  def as_json(*)
    to_sql
  end

  class << self
    # Given a value, attempt to parse it into a {VariablePrecisionDate}. It will always
    # return a date, swallowing any parser errors. If something cannot be parsed, this
    # method will return a `:none`-valued date.
    #
    # @param [String, Date, Hash, VariablePrecisionDate] value
    # @return [VariablePrecisionDate]
    def parse(value)
      case value
      when ::VariablePrecisionDate
        value
      when ::Time, ::DateTime
        # It's important to try DateTime before Date, as DateTime < Date
        new value.to_date, :day
      when SQL_REPRESENTATION
        parse_sql value
      when ::Date, Dry::Types["json.date"]
        new value, :day
      when YEAR_INT
        from_year value
      when YEAR_MONTH
        from_month Regexp.last_match[:year], Regexp.last_match[:month]
      when YEAR_ONLY
        from_year Regexp.last_match[:year]
      when XMLSCHEMA_TIME_FORMAT
        parse Time.xmlschema(value)
      when HashSchema
        validated = HashSchema[value]

        new validated[:value], validated[:precision]
      else
        none
      end
    end

    # This will parse a `variable_precision_date` from the database.
    #
    # @api private
    # @param [String] sql_string
    # @return [VariablePrecisionDate]
    def parse_sql(sql_string)
      decoded = DECODER.decode sql_string

      return new(nil, :none) if decoded.blank?

      value = parse_sql_date decoded[0]

      return new(nil, :none) if value.blank?

      precision = parse_sql_precision decoded[1]

      new value, precision
    end

    # Create a `:month`-valued variable precision date.
    #
    # @see VariablePrecisionDate::Precision
    # @param [#to_i] year_value
    # @param [#to_i] month_value
    # @return [VariablePrecisionDate]
    def from_month(year_value, month_value)
      value = Date.new year_value.to_i, month_value.to_i, 1

      new value, :month
    end

    # Create a `:year`-valued variable precision date.
    #
    # @see VariablePrecisionDate::Precision
    # @param [#to_i] year_value
    # @return [VariablePrecisionDate]
    def from_year(year_value)
      value = Date.new year_value.to_i, 1, 1

      new value, :year
    end

    # Create a `:none`-valued date.
    #
    # @see VariablePrecisionDate::Precision
    # @return [VariablePrecisionDate]
    def none
      new nil, :none
    end

    private

    # @param [String] value an ISO8601-encoded date value from the internal representation of a date
    # @return [Date, nil]
    def parse_sql_date(value)
      Date.parse value
    rescue Date::Error, TypeError
      # :nocov:
      nil
      # :nocov:
    end

    # @param [String] precision a value corresponding to {VariablePrecisionDate::Precision}.
    # @return [:none, :year, :month, :day]
    def parse_sql_precision(precision)
      case precision
      when Precision
        Precision[precision]
      else
        # :nocov:
        :none
        # :nocov:
      end
    end
  end

  ParseType = Dry::Types::Constructor.new(self, fn: method(:parse))
end
