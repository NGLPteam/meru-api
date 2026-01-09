# frozen_string_literal: true

GraphQL::FragmentCache.configure do |config|
  config.cache_store = Rails.cache
end

ActiveSupport::Notifications.subscribe(/graphql/) do |event|
  # :nocov:
  name = event.name

  duration = event.duration.round(2)

  next if duration < 10.0

  operation_name = Support::Requests::Current.graphql_operation_name

  query = event.payload[:query]

  field = event.payload[:field]

  current_path = query.try(:context).try(:current_path).try(:join, ?.) || field.try(:path)

  step = {
    name:,
    current_path:,
    duration: event.duration,
  }

  Support::Requests::Current.graphql_steps << step

  next unless MeruConfig.log_slow_fields?

  tags = ["graphql", operation_name, name]

  tags << current_path if name == "graphql.execute_field" && current_path.present?

  prefix = tags.compact_blank.map { |tag| "[#{tag}]" }.join

  Rails.logger.info("#{prefix} Completed in #{duration}ms")
  # :nocov:
end
