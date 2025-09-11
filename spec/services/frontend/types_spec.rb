# frozen_string_literal: true

RSpec.describe Frontend::Types do
  shared_examples_for "valid response time conversions" do
    it "can handle a JavaScript timestamp" do
      now = Time.current

      stamp = (now.to_i * 1000)

      expect do
        expect(type[stamp]).to be_within(1.second).of(now)
      end.to execute_safely
    end

    it "can handle an ISO8601 timestamp" do
      now = Time.current

      iso = now.iso8601

      expect do
        expect(type[iso]).to be_within(1.second).of(now)
      end.to execute_safely
    end

    it "can handle a Ruby Time" do
      # We are intentionally testing ruby's base time class.
      now = Time.now # rubocop:disable Rails/TimeZone

      expect do
        expect(type[now]).to eq(now.in_time_zone)
      end.to execute_safely
    end

    it "can handle a TimeWithZone" do
      now = Time.current

      expect do
        expect(type[now]).to eq(now)
      end.to execute_safely
    end
  end

  describe "ResponseTime" do
    let(:type) { described_class::ResponseTime }

    include_examples "valid response time conversions"

    it "blows up with nil" do
      expect do
        type[nil]
      end.to raise_error(Dry::Types::CoercionError)
    end

    it "blows up with an invalid string" do
      expect do
        type["not a time"]
      end.to raise_error(Dry::Types::CoercionError)
    end

    it "blows up with an empty string" do
      expect do
        type[""]
      end.to raise_error(Dry::Types::CoercionError)
    end

    it "blows up with an invalid type" do
      expect do
        type[[]]
      end.to raise_error(Dry::Types::CoercionError)
    end
  end

  describe "SafeResponseTime" do
    let(:type) { described_class::SafeResponseTime }

    include_examples "valid response time conversions"

    it "handles nil" do
      expect do
        expect(type[nil]).to be_nil
      end.to execute_safely
    end

    it "handles an empty string" do
      expect do
        expect(type[""]).to be_nil
      end.to execute_safely
    end

    it "handles an invalid string" do
      expect do
        expect(type["not a time"]).to be_nil
      end.to execute_safely
    end

    it "handles an invalid type" do
      expect do
        expect(type[[]]).to be_nil
      end.to execute_safely
    end
  end
end
