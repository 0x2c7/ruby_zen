module RubyZen::Interpreters
  class LeaveInterpreter < Base
    interpret 'leave'

    def call(vm, _instruction)
      if vm.environment.scope.is_a?(RubyZen::MethodObject)
        return_object = vm.environment.last_frame.pop
        vm.environment.scope.add_return_object(return_object)
      end
    end
  end
end
