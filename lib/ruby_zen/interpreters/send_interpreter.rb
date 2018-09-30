module RubyZen::Interpreters
  class SendInterpreter < Base
    interpret 'send'

    def call(vm, instruction)
      call_info, _call_cache, block_iseq = instruction.operands
      case call_info.mid
      when :define_method
        handle_define_method(vm, block_iseq)
      when :define_singleton_method
        handle_define_singleton_method(vm, block_iseq)
      else
        logger.debug("Method #{call_info.mid} not handled.")
      end
    end

    private

    def handle_define_method(vm, method_body)
      method_name = vm.environment.pop
      receiver = vm.environment.pop

      method_object = vm.define_instance_method(receiver, method_name, method_body)

      vm.run(method_body, scope: method_object, self_pointer: receiver.instance)

      vm.environment.push(method_object)
    end

    def handle_define_singleton_method(vm, method_body)
      method_name = vm.environment.pop
      receiver = vm.environment.pop

      method_object = vm.define_class_method(receiver, method_name, method_body)

      vm.run(method_body, scope: method_object, self_pointer: receiver)

      vm.environment.push(method_object)
    end
  end
end
