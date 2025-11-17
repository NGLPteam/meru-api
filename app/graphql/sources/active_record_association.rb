# frozen_string_literal: true

module Sources
  class ActiveRecordAssociation < GraphQL::Dataloader::ActiveRecordAssociationSource
    # @param [Class<ActiveRecord::Base>] model_class
    # @param [Symbol] association_name
    def initialize(model, association_name)
      super(association_name, nil)

      @model = model
      @association_name = association_name

      validate!
    end

    # @param [<ApplicationRecord>] records
    # @return [<ActiveRecord::Relation, ApplicationRecord, nil>]
    # def fetch(records)
    #  preload_association!(records)

    #  records.map { read_association(_1) }
    # end

    private

    # @param [ApplicationRecord] record
    # def association_loaded?(record)
    #  record.association(@association_name).loaded?
    # end

    # @param [<ApplicationRecord>] records
    # @return [void]
    # def preload_association!(records)
    #   ::ActiveRecord::Associations::Preloader.new(records:, associations: [@association_name]).call
    # end

    # @param [ApplicationRecord] record
    # @return [ActiveRecord::Relation, ApplicationRecord, nil]
    # def read_association(record)
    #   record.public_send(@association_name)
    # end

    # @return [void]
    def validate!
      # :nocov:
      raise ArgumentError, "No association #{@association_name} on #{@model}" unless @model.reflect_on_association(@association_name)
      # :nocov:
    end
  end
end
