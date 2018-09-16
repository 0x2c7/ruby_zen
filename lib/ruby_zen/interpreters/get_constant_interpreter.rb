module RubyZen::Interpreters
  class GetConstantInterpreter < Base
    interpret 'getconstant'

    def call(vm, instruction)
      namespace = vm.environment.pop
      name = instruction.operands[0]
      name = "#{namespace.fullname}::#{name}" unless namespace.nil?

      constant_value =
        vm.engine.fetch_class(name) ||
        vm.engine.define_class(name) do
          RubyZen::ClassObject.new(name, is_module: true)
        end

      vm.environment.push(constant_value)
    end
  end
end
