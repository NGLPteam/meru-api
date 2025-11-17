# frozen_string_literal: true

class Isolated
  def call(&block)
    Async do
      Thread.new do
        block.call
      end.value
    end
  end

  class << self
    def isolate!(&)
      new.call(&)
    end
  end
end
