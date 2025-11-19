# frozen_string_literal: true

class EntityTaskRevalidator
  include Dry::Monads[:result, :maybe]
  include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

  # @param ["collection", "community", "item"] kind
  # @param [String] slug_or_id
  # @return [Dry::Monads::Result]
  def call(kind, slug_or_id)
    klass = klass_for(kind)

    find_with(klass, slug_or_id).to_result.tee(&:revalidate_frontend_cache)
  end

  private

  # @param [Class] klass
  # @param [String] slug_or_id
  def find_with(klass, slug_or_id)
    case slug_or_id
    in Support::GlobalTypes::UUID => id
      Maybe(klass.find_by(id:))
    else
      Maybe(klass)
    end
  end

  # @param ["collection", "community", "item"] kind
  # @return [Class]
  def klass_for(kind)
    case kind.to_s
    when "community"
      ::Community
    when "collection"
      ::Collection
    when "item"
      ::Item
    else
      # :nocov:
      raise ArgumentError, "Unknown kind: #{kind.inspect}"
      # :nocov:
    end
  end

  class << self
    def run!(kind, slug_or_id)
      new.call(kind, slug_or_id) do |m|
        m.success do |entity|
          puts "Revalidated #{entity.inspect} successfully"
        end

        m.failure do
          puts "Could not find #{kind} with identifier: #{slug_or_id.inspect}"
          exit 1
        end
      end
    end
  end
end

namespace :revalidate do
  desc "Revalidate an entire instance"
  task instance: :environment do
    MeruAPI::Container["frontend.cache.revalidate_instance"].().value!

    puts "Revalidation triggered for entire instance"
  end

  desc "Revalidate a specific community"
  task :community, %i[slug_or_id] => :environment do |t, args|
    EntityTaskRevalidator.run!("community", args[:slug_or_id])
  end

  desc "Revalidate a specific collection"
  task :collection, %i[slug_or_id] => :environment do |t, args|
    EntityTaskRevalidator.run!("collection", args[:slug_or_id])
  end

  desc "Revalidate a specific item"
  task :item, %i[slug_or_id] => :environment do |t, args|
    EntityTaskRevalidator.run!("item", args[:slug_or_id])
  end
end
