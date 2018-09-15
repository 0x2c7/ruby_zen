module RubyZen::Indexers
  class IseqIndexer
    attr_reader :iseq

    def initialize(
      code, engine:, logger:,
      interpreter_registry: RubyZen::InterpreterRegistry.instance
    )
      @engine = engine
      @code = code
      @logger = logger

      @interpreter_registry = interpreter_registry.prepare(logger: logger)
      @vm = RubyZen::VM.new(
        engine: @engine,
        logger: @logger,
        interpreter_registry: @interpreter_registry
      )
    end

    def start
      iseq = YarvGenerator.build_from_source(@code)
      @vm.run(iseq)
    end
  end
end
