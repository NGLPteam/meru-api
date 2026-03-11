# frozen_string_literal: true

module EsploroSchema
  module Types
    extend ::Support::Typespace

    ENUM_TYPE = ->(type) do
      return false unless type.kind_of?(::Dry::Types::Type)

      return true if type.kind_of?(::Dry::Types::Enum)

      flattened_ast = ::Kernel.Array(type.to_ast).flatten

      :enum.in?(flattened_ast)
    end

    DryEnum = Instance(::Dry::Types::Type).constrained(case: ENUM_TYPE)

    DryType = Instance(::Dry::Types::Type)

    MapperType = Symbol | Class

    Stringish = Coercible::String.constrained(filled: true)

    StringishList = Coercible::Array.of(Stringish)

    UnwrappedAttributeName = Symbol.constrained(filled: true)

    WrappedAttributeName = Symbol.constrained(filled: true)

    WrappedAttributeMapping = Hash.map(WrappedAttributeName, UnwrappedAttributeName)

    # @!group Enums

    # @see https://developers.exlibrisgroup.com/esploro/apis/xsd/esploro_record.xsd/#AccessStatus
    AccessStatus = Coercible::String.default("unknown").enum("yes", "no", "unknown").fallback("unknown")

    # @see https://developers.exlibrisgroup.com/esploro/apis/xsd/esploro_record.xsd/#ActionType
    ActionType = Coercible::String.enum("copy", "replace")

    # @see https://developers.exlibrisgroup.com/esploro/apis/xsd/esploro_record.xsd/#esploroAssetToAssetRelationshipType
    EsploroAssetToAssetRelationshipType = Coercible::String.enum("EXTERNAL", "INTERNAL")

    # @see https://developers.exlibrisgroup.com/esploro/apis/xsd/esploro_record.xsd/#EsploroResourceType
    EsploroResourceType = Coercible::String.enum(
      "creativeWork.musicalComposition",
      "creativeWork.musicalPerformance",
      "interactiveResource.webinar",
      "interactiveResource.blog",
      "creativeWork.poetry",
      "etdexternal.undergraduate_external",
      "creativeWork.sculpture",
      "publication.conferenceProceeding",
      "publication.technicalDocumentation",
      "publication.annotation",
      "etdexternal.doctoral_external",
      "creativeWork.theater",
      "etd",
      "interactiveResource.website",
      "dataset.dataset",
      "publication.dictionaryEntry",
      "etd.graduate",
      "etdex",
      "publication",
      "creativeWork.choreography",
      "publication.encyclopediaEntry",
      "conference",
      "publication.report",
      "publication.letter",
      "publication.abstract",
      "creativeWork.nonFiction",
      "conference.conferenceProgram",
      "conference.conferencePaper",
      "postedContent.preprint",
      "publication.book",
      "publication.newspaperArticle",
      "other.map",
      "etd.undergraduate",
      "patent.patent",
      "creativeWork.dance",
      "patent",
      "other.model",
      "creativeWork.essay",
      "conference.conferencePoster",
      "interactiveResource",
      "other.other",
      "publication.journalArticle",
      "publication.translation",
      "creativeWork.newMedia",
      "conference.conferencePresentation",
      "creativeWork.exhibitionCatalog",
      "dataset",
      "creativeWork.setDesign",
      "creativeWork.script",
      "conference.presentation",
      "software",
      "interactiveResource.virtualRealityEnvironment",
      "publication.editedBook",
      "interactiveResource.podcast",
      "creativeWork.painting",
      "postedContent.workingPaper",
      "creativeWork.other",
      "publication.bookChapter",
      "publication.bookReview",
      "creativeWork.drama",
      "creativeWork.designAndArchitecture",
      "publication.newsletterArticle",
      "conference.eventposter",
      "creativeWork.fiction",
      "etdexternal.graduate_external",
      "postedContent.acceptedManuscript",
      "other",
      "publication.editorial",
      "creativeWork.musicalScore",
      "software.code",
      "creativeWork",
      "publication.journalIssue",
      "publication.magazineArticle",
      "software.workflow",
      "publication.bibliography",
      "etd.doctoral",
      "postedContent",
      "creativeWork.film",
      "teaching",
      "teaching.assignment",
      "teaching.workbook",
      "teaching.flashcards",
      "teaching.lecture",
      "teaching.outline",
      "teaching.coursemodule",
      "teaching.studyguide",
      "teaching.syllabus",
      "teaching.activity",
      "teaching.casestudy",
      "teaching.manual",
      "teaching.questionbank",
      "teaching.textbook",
      "teaching.tutorial",
      "teaching.demonstration",
      "teaching.other"
    )

    # @see https://developers.exlibrisgroup.com/esploro/apis/xsd/esploro_record.xsd/#RelationType
    RelationType = Coercible::String.enum(
      "requires",
      "isbasedon",
      "ispartof",
      "iscommenton",
      "ismanifestationof",
      "isretractionof",
      "iscompiledby",
      "retraction",
      "references",
      "isdescribedby",
      "haspreprint",
      "isversionof",
      "iscorrectionof",
      "hasversion",
      "hastranslation",
      "cites",
      "is_supplemented_by",
      "reviews",
      "hasmanifestation",
      "isreviewedby",
      "cited_by",
      "isrequiredby",
      "isbasisfor",
      "isexpressionof",
      "isoriginalformof",
      "ispreprintof",
      "hasformat",
      "isidenticalto",
      "describes",
      "iscontinuedby",
      "hascomment",
      "hasexpression",
      "isdocumentedby",
      "hasreply",
      "hasrelatedmaterial",
      "conformsto",
      "continues",
      "isformatof",
      "istranslationof",
      "ispublicationof",
      "issupplementto",
      "isreplacedby",
      "haspart",
      "documents",
      "isderivedfrom",
      "isvariantformof",
      "hasmetadata",
      "isrelatedmaterial",
      "hasaccepted",
      "replaces",
      "ismetadatafor",
      "isrelatedto",
      "isnewversionof",
      "ispreviousversionof",
      "isreferencedby",
      "isdataof",
      "compiles",
      "isreplyto",
      "correction",
      "issameas",
      "issourceof",
      "isacceptedof",
      "iscodeof",
      "isprerequisiteof",
      "hasprerequisite"
    )

    # @note Does not appear to be used, but is specifically defined in the XSD and mentioned in the documentation,
    #   so leaving here in case it gets adopted in the future.
    # @see https://developers.exlibrisgroup.com/esploro/apis/xsd/esploro_record.xsd/#type
    Type = Coercible::String.enum("REJECT", "WARNING")

    # @see https://developers.exlibrisgroup.com/esploro/apis/xsd/esploro_record.xsd/#YesNoUnknown
    YesNoUnknown = Coercible::String.default("unknown").enum("yes", "no", "unknown").fallback("unknown")

    # @!endgroup
  end
end
