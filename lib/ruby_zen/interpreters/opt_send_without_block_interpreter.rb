module RubyZen::Interpreters
  class OptSendWithoutBlockInterpreter < Base
    interpret 'opt_send_without_block'

    def call(vm, instruction)
      call_info, _call_cache = instruction.operands
      case call_info.mid
      when :"core#define_method", :define_method
        handle_define_method(vm)
      when :"core#define_singleton_method", :define_singleton_method
        handle_define_singleton_method(vm)
      when :instance_method
        handle_instance_method(vm)
      when :method
        handle_method(vm)
      when :include
        handle_include(vm)
      when :extend
        handle_extend(vm)
      when :prepend
        handle_prepend(vm)
      else
        logger.debug("Method #{call_info.mid} not handled.")
      end
    end

    private

    def handle_define_method(vm)
      receiver = vm.scope.last
      method_body = vm.environment.pop
      method_name = vm.environment.pop

      method_object = vm.define_instance_method(receiver, method_name, method_body)

      if method_body.is_a?(YarvGenerator::Iseq)
        vm.environment.new_frame
        vm.environment.push(method_object)
        vm.scope.push(vm.scope.last)
        vm.run(method_body)
      end

      vm.environment.push(method_object)
    end

    def handle_define_singleton_method(vm)
      method_body = vm.environment.pop
      method_name = vm.environment.pop
      receiver = vm.environment.pop

      method_object = vm.define_class_method(receiver, method_name, method_body)

      if method_body.is_a?(YarvGenerator::Iseq)
        vm.environment.new_frame
        vm.environment.push(method_object)
        vm.scope.push(vm.scope.last)
        vm.run(method_body)
      end

      vm.environment.push(method_object)
    end

    def handle_instance_method(vm)
      method_name = vm.environment.pop
      receiver = vm.environment.pop

      method_object = receiver.instance_method_object(method_name)
      vm.environment.push(method_object)
    end

    def handle_method(vm)
      method_name = vm.environment.pop
      receiver = vm.environment.pop

      method_object = receiver.class_method_object(method_name)
      vm.environment.push(method_object)
    end

    def handle_include(vm)
      module_definition = vm.environment.pop
      receiver = vm.environment.pop

      receiver.include_module(module_definition)
    end

    def handle_extend(vm)
      module_definition = vm.environment.pop
      receiver = vm.environment.pop

      receiver.extend_module(module_definition)
    end

    def handle_prepend(vm)
      module_definition = vm.environment.pop
      receiver = vm.environment.pop

      receiver.prepend_module(module_definition)
    end
  end
end
