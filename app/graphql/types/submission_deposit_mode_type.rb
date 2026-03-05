# frozen_string_literal: true

module Types
  class SubmissionDepositModeType < Types::BaseEnum
    description <<~TEXT
    The mode of deposit for a submission target. This defines where deposits are made
    relative to the entity specified by the submission target.
    TEXT

    value "DIRECT", value: "direct" do
      description <<~TEXT
      Deposits on the submission target are made directly to the entity specified.
      TEXT
    end

    value "DESCENDANT", value: "descendant" do
      description <<~TEXT
      Deposits to the submission target are made to a descendant of the specified entity.

      For instance, if the submission target is defined on a `nglp:journal`,
      deposits of an `nglp:journal_article` might be made to `nglp:journal_issue`
      entities that are descendants of the journal.
      TEXT
    end
  end
end
