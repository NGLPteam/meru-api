# frozen_string_literal: true

ActiveSupport::Notifications.subscribe(/graphql/) do |event|
  name = event.name

  duration = event.duration.round(2)

  # :nocov:
  next if duration < 10.0
  # :nocov:

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

  tags = ["graphql", operation_name, name]

  tags << current_path if name == "graphql.execute_field" && current_path.present?

  prefix = tags.compact_blank.map { |tag| "[#{tag}]" }.join

  Rails.logger.info("#{prefix} Completed in #{duration}ms")
end
