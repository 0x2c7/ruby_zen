module RubyZen::Interpreters
  class LeaveInterpreter < Base
    interpret 'leave'

    def call(vm, _instruction)
      vm.environment.leave_frame
    end
  end
end
