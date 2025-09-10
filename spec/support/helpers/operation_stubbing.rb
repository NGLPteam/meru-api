# frozen_string_literal: true

module TestHelpers
  module OperationStubbing
    module SpecHelpers
      def stub_operation!(path, as:, stub_class: TestHelpers::TestOperation, container: Common::Container, auto_succeed: false, &block)
        if block_given?
          let(as, &block)
        else
          let(as) { instance_double(stub_class) }
        end

        around do |example|
          RSpec::Mocks.with_temporary_scope do
            container.stub(path, public_send(as)) do
              example.run
            end
          end
        end

        if auto_succeed
          before do
            allow(public_send(as)).to receive(:call).and_return(Dry::Monads.Success())
          end
        end
      end
    end
  end
end

RSpec.configure do |c|
  c.extend TestHelpers::OperationStubbing::SpecHelpers
end
