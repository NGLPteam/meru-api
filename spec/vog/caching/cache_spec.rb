# frozen_string_literal: true

RSpec.describe Support::Caching::Cache do
  # @note We don't use let here because we want a simple
  # method that doesn't work with RSpec's scoping, which
  # fibers / threads may interfere with.
  def instance
    described_class.instance
  end

  subject { instance }

  describe "#with_vog_cache" do
    it "activates the vog cache within the block in a thread & fiber-safe manner", :aggregate_failures do
      is_expected.not_to be_vog_cache_active

      instance.with_vog_cache do
        is_expected.to be_vog_cache_active

        expect(instance.vog_safe_cache).to be_a(Concurrent::Map)

        expect do
          fib1 = Fiber.new do
            instance.vog_cache(:test) { "set in fiber1" }

            Fiber.yield
          end

          fib1.resume
          fib1.resume
        end.to change { instance.vog_safe_cache.size }.by(1)
          .and change { instance.vog_safe_cache.key?(%i[test]) }

        cached = instance.vog_cache(:test) { "diff value" }

        expect(cached).to eq("set in fiber1")
      end

      expect(instance.vog_safe_cache).to be_nil

      is_expected.not_to be_vog_cache_active
    end
  end
end
