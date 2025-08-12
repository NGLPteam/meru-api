# frozen_string_literal: true

Rails.application.configure do
  # Future-proofing
  config.good_job.smaller_number_is_higher_priority = true

  queues = [
    "maintenance:1",
    "rendering:1",
    "+purging,hierarchies,entities,orderings,invalidations,layouts:2",
    "+harvest_pruning,extraction,harvesting,asset_fetching:4",
    "permissions,processing,default,mailers,ahoy:2",
  ].join(?;)

  config.good_job.cleanup_preserved_jobs_before_seconds_ago = 43_200 # half-day
  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  # config.good_job.on_thread_error = ->(exception) { Rollbar.error(exception) }
  # :nocov:
  config.good_job.execution_mode = Rails.env.test? ? :inline : :external
  # :nocov:
  config.good_job.queues = queues
  config.good_job.max_threads = 10
  config.good_job.poll_interval = 10 # seconds
  config.good_job.shutdown_timeout = 25 # seconds
  config.good_job.advisory_lock_heartbeat = true
  config.good_job.enable_cron = !Rails.env.test?
  config.good_job.enable_listen_notify = true
  config.good_job.enable_pauses = true
  config.good_job.queue_select_limit = 1000
  config.good_job.dashboard_live_poll_enabled = false
  config.good_job.inline_execution_respects_schedule = true
  config.good_job.cron = {
    "access.enforce_assignments": {
      cron: "*/5 * * * *",
      class: "Access::EnforceAssignmentsJob",
      description: "Audit assignments and make sure everything looks correct.",
    },
    "attributions.collections.manage": {
      cron: "*/10 * * * *",
      class: "Attributions::Collections::ManageJob",
      description: "Ensure collection attributions are up to date",
    },
    "attributions.items.manage": {
      cron: "*/10 * * * *",
      class: "Attributions::Items::ManageJob",
      description: "Ensure item attributions are up to date",
    },
    "contributors.audit_contribution_counts": {
      cron: "*/5 * * * *",
      class: "Contributors::AuditContributionCountsJob",
      description: "Ensure contribution counts are up to date",
    },
    "contributors.refresh_attributions": {
      cron: "*/10 * * * *",
      class: "Contributors::RefreshAttributionsJob",
      description: "Ensure contributor attributions are up to date",
    },
    "controlled_vocabularies.populate_sources": {
      cron: "*/15 * * * *",
      class: "ControlledVocabularies::PopulateSourcesJob",
      description: "Ensure all possible controlled vocabulary sources are populated.",
    },
    "entities.audit_authorizing": {
      cron: "*/5 * * * *",
      class: "Entities::AuditAuthorizingJob",
      description: "Audit authorizing entities",
    },
    "entities.audit_hierarchies": {
      cron: "*/5 * * * *",
      class: "Entities::AuditHierarchiesJob",
      description: "Audit authorizing entities",
    },
    "entities.audit_mismatched_schemas": {
      cron: "*/5 * * * *",
      class: "Entities::AuditMismatchedSchemasJob",
      description: "Audit mismatched schemas for entities",
    },
    "entities.derive_layout_definitions": {
      cron: "4,24,44 * * * *",
      class: "Entities::DeriveLayoutDefinitionsJob",
      description: "Derive layout definitions for each entity system-wide",
    },
    "entities.populate_missing_orderings": {
      cron: "*/10 * * * *",
      class: "Entities::PopulateMissingOrderingsJob",
      description: "Populate any missing orderings on entities",
    },
    "entities.populate_visibilities": {
      cron: "*/10 * * * *",
      class: "Entities::PopulateVisibilitiesJob",
      description: "Populate entity visibilities",
    },
    "entities.refresh_author_contributions": {
      cron: "7,17,27,37,47,57 * * * *",
      class: "Entities::RefreshAuthorContributionsJob",
      description: "Refresh author contributions",
    },
    "entities.refresh_cached_ancestors": {
      cron: "*/2 * * * *",
      class: "Entities::RefreshCachedAncestorsJob",
      description: "Refresh entity cached ancestors",
    },
    "entities.reindex_all_search_documents": {
      cron: "9,19,29,39,49,59 * * * *",
      class: "Entities::ReindexAllSearchDocumentsJob",
      description: "Re-index all entity search documents",
    },
    "harvesting.attempts.enqueue_scheduled": {
      cron: "50 * * * *",
      class: "Harvesting::Attempts::EnqueueScheduledJob",
      description: "Enqueue scheduled attempts",
    },
    "harvesting.mappings.schedule_all_attempts": {
      cron: "30 6 * * *",
      class: "Harvesting::Mappings::ScheduleAllAttempts",
      description: "Schedule all attempts once a day.",
    },
    "ordering_invalidations.process_all": {
      cron: "*/5 * * * *",
      class: "OrderingInvalidations::ProcessAllJob",
      description: "Process stale orderings",
      args: -> { [Time.current.iso8601] },
    },
    "rendering.process_stale_entities": {
      cron: "*/5 * * * *",
      class: "Rendering::ProcessStaleEntitiesJob",
      description: "Process stale entities to re-render",
      args: -> { [Time.current.iso8601] }
    },
    "schemas.orderings.refresh_counts": {
      cron: "*/10 * * * *",
      class: "Schemas::Orderings::RefreshEntryCountsJob",
      description: "Refresh ordering entry counts",
    },
    "system.collect_pg_hero_query_stats": {
      cron: "*/5 * * * *",
      class: "System::CollectPgHeroQueryStatsJob",
      description: "Collect PGHero Query Stats",
    },
    "system.collect_pg_hero_space_stats": {
      cron: "8 * * * *",
      class: "System::CollectPgHeroSpaceStatsJob",
      description: "Collect PGHEro Space Stats",
    },
    "system.clean_pg_hero_query_stats": {
      cron: "45 22 * * 6",
      class: "System::CleanPgHeroQueryStatsJob",
      description: "Clean up PG Hero Query Stats",
    },
    "system.clean_pg_hero_space_stats": {
      cron: "45 22 * * 6",
      class: "System::CleanPgHeroSpaceStatsJob",
      description: "Clean up PG Hero Space Stats",
    }
  }

  config.good_job.dashboard_default_locale = :en
end

GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  SecurityConfig.validate_basic_auth?(username, password)
end unless Rails.env.development?

GoodJob::Engine.middleware.use Rack::MethodOverride
GoodJob::Engine.middleware.use ActionDispatch::Flash
GoodJob::Engine.middleware.use ActionDispatch::Cookies
GoodJob::Engine.middleware.use ActionDispatch::Session::CookieStore
