module RubyZen::Interpreters
  class GetLocalInterpreter < Base
    GETLOCAL_PATTERN = /^getlocal_OP__WC__(0|1)$/.freeze
    interpret GETLOCAL_PATTERN

    def call(vm, instruction)
      level, index = extract_local(instruction)
      vm.environment.push(
        vm.environment.local(level, index)
      )
    end

    private

    def extract_local(instruction)
      match = instruction.name.match(GETLOCAL_PATTERN)
      [match[1].to_i, instruction.operands.first]
    end
  end
end
