# frozen_string_literal: true

module SubmissionTargets
  # The description for an {SubmissionTarget}, grouping together multiple {SubmissionTargets::Section}s.
  class Description
    include Support::EnhancedStoreModel

    # @!attribute [rw] internal
    #   The internal description for a submission target. This should be short and concise.
    #   @return [String]
    attribute :internal, :string, default: ""

    # @!attribute [rw] instructions
    #   The instructions for a submission target, which preface any other sections.
    #   @return [String]
    attribute :instructions, :string, default: ""

    # @!attribute [rw] sections
    #   The sections that make up the description.
    #   @return [Array<SubmissionTargets::Section>]
    attribute :sections, SubmissionTargets::Section.to_array_type, default: Dry::Core::Constants::EMPTY_ARRAY

    strip_attributes only: %i[internal instructions], allow_empty: true

    before_validation :generate_section_ids!

    validates :sections, store_model: true

    private

    # @return [void]
    def enforce_section_positions!
      sections.each_with_index do |section, index|
        section.position = index + 1
      end
    end

    # @return [void]
    def generate_section_ids!
      enforce_section_positions!

      sections.each_with_object({}) do |section, seen_ids|
        base_identifier = section.base_identifier

        next if base_identifier.blank?

        section.identifier = base_identifier

        seen_ids[base_identifier] ||= section

        next if seen_ids[base_identifier] == section

        section.identifier = "#{base_identifier}--#{section.position}"

        seen_ids[section.identifier] ||= section

        # :nocov:
        # This should never happen, as the position is included in the ID, but we want to be sure that we don't generate duplicate IDs.
        raise "Duplicate section ID generated: #{section.identifier}" if seen_ids[section.identifier] != section
        # :nocov:
      end
    end
  end
end
