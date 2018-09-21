module RubyZen::Interpreters
  class SetLocalInterpreter < Base
    SETLOCAL_PATTERN = /^setlocal_OP__WC__(0|1)$/.freeze
    interpret SETLOCAL_PATTERN

    def call(vm, instruction)
      level, index = extract_local(instruction)
      value = vm.environment.pop
      vm.environment.local(level, index).replace(value)
    end

    private

    def extract_local(instruction)
      match = instruction.name.match(SETLOCAL_PATTERN)
      [match[1].to_i, instruction.operands.first]
    end
  end
end
