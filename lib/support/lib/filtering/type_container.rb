# frozen_string_literal: true

module Support
  module Filtering
    class TypeContainer < Support::DryGQL::TypeContainer
      add_model! "User"

      add_enum_type! ::Support::GQL::FullTextSearchStrategyType

      private

      # @return [void]
      compile! def define_filter_inputs!
        add! :full_text_search_query, ::Support::FullTextSearching::Query::Type

        add! :date_match, ::Support::Filtering::Inputs::DateMatch

        add! :float_match, ::Support::Filtering::Inputs::FloatMatch

        add! :integer_match, ::Support::Filtering::Inputs::IntegerMatch

        add! :time_match, ::Support::Filtering::Inputs::TimeMatch
      end
    end
  end
end
