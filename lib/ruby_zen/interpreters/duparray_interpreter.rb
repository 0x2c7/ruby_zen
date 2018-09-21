module RubyZen::Interpreters
  class DuparrayInterpreter < Base
    interpret 'duparray'

    ARRAY_CLASS = 'Array'.freeze

    def call(vm, instruction)
      vm.environment.push(
        RubyZen::MaybeClassObject.new(
          vm.engine.define_class(ARRAY_CLASS)
        )
      )
    end
  end
end
