module RubyZen::Interpreters
  class DefineClassInterpreter < Base
    interpret 'defineclass'

    def call(vm, instruction)
      superclass = vm.environment.pop
      cbase = vm.environment.pop

      class_name, class_body, flags = instruction.operands
      class_name = "#{cbase.fullname}::#{class_name}" unless cbase.nil?

      class_value = create_class_object(vm, class_name, superclass, cbase, flags)

      vm.run(class_body, class_value)
    end

    private

    def create_class_object(vm, class_name, superclass, cbase, flags)
      if (flags & 0x1) > 0
        # Singleton class
        cbase.singleton_class
      elsif (flags & 0x2) > 0
        # Module
        vm.engine.define_class(class_name) do
          RubyZen::ClassObject.new(
            class_name, is_module: true, namespace: cbase
          )
        end
      else
        # Normal class
        vm.engine.define_class(class_name) do
          RubyZen::ClassObject.new(
            class_name,
            superclass: superclass,
            namespace: cbase
          )
        end
      end
    end
  end
end
