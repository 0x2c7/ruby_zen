module RubyZen::Interpreters
  class GetInlineCacheInterpreter < Base
    interpret 'getinlinecache'

    def call(vm, instruction)
      vm.environment.push(nil)
    end
  end

  class SetInlineCacheInterpreter < Base
    interpret 'setinlinecache'

    def call(vm, instruction)
      val = vm.environment.pop
      vm.environment.push(val)
    end
  end
end
