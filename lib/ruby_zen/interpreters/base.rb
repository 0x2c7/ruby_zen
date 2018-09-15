module RubyZen::Interpreters
  class Base
    def self.interpret(instruction)
      RubyZen::InterpreterRegistry.instance.add(instruction, self)
    end

		attr_reader :logger

    def initialize(logger:)
      @logger = logger
    end
  end
end
