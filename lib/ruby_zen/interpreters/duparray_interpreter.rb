module RubyZen::Interpreters
  class DuparrayInterpreter < Base
    interpret 'duparray'

    ARRAY_CLASS = 'Array'.freeze

    def call(vm, instruction)
      vm.environment.push(
        RubyZen::MaybeObject.new(
          vm.engine.define_class(ARRAY_CLASS).instance
        )
      )
    end
  end
end
