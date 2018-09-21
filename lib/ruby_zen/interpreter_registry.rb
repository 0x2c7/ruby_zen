module RubyZen
  class InterpreterMatcher
    attr_reader :pattern, :interpreter

    def initialize(pattern, interpreter)
      @pattern = pattern
      @interpreter = interpreter
    end
  end

  class InterpreterRegistry
    def self.instance
      @instance ||= self.new
    end

    def initialize(interpreters: {}, interpreter_matchers: [])
      @interpreters = interpreters
      @interpreter_matchers = interpreter_matchers
    end

    def prepare(logger:)
      InterpreterRegistry.new(
        interpreters: @interpreters.each_with_object({}) do |(key, value), registry|
          registry[key] = value.new(logger: logger)
        end,
        interpreter_matchers: @interpreter_matchers.map do |matcher|
          InterpreterMatcher.new(
            matcher.pattern,
            matcher.interpreter.new(logger: logger)
          )
        end
      )
    end

    def add(instruction, interpreter)
      case instruction.class.name
      when 'String', 'Symbol'
        instruction_name = instruction.to_s
        if @interpreters.key?(instruction_name)
          raise "Interpreter for `#{instruction_name}` instruction already exists!"
        else
          @interpreters[instruction_name] = interpreter
        end
      when 'Regexp'
        @interpreter_matchers << InterpreterMatcher.new(instruction,interpreter)
      else
        raise 'Invalid interpreter matching'
      end
    end

    def interpreter_for(instruction)
      return @interpreters[instruction] if @interpreters.key?(instruction)

      matcher = @interpreter_matchers.find do |matcher|
        instruction =~ matcher.pattern
      end&.interpreter
    end
  end
end
