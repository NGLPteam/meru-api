# frozen_string_literal: true

module LiquidExt
  module Behavior
    module BlankAndPresent
      extend ActiveSupport::Concern

      # Rails-ish `blank?` predicate for use in liquid contexts.
      #
      # @return [Boolean]
      def is_blank
        # simplecov:disable
        blank_for_liquid?
        # simplecov:enable
      end

      # Rails-ish `present?` predicate for use in liquid contexts.
      #
      # @return [Boolean]
      def is_present
        # simplecov:disable
        !blank_for_liquid?
        # simplecov:enable
      end

      def to_liquid
        return nil if is_blank

        super
      end

      private

      # @abstract
      def blank_for_liquid?
        # simplecov:disable
        blank?
        # simplecov:enable
      end
    end
  end
end
