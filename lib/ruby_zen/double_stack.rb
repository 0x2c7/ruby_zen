module RubyZen
  class DoubleStack
    def initialize
      @stacks = [[]]
    end

    def push(val)
      @stacks.last.push(val)
    end

    def pop
      @stacks.last.pop
    end

    def new_frame
      @stacks.push([])
    end

    def leave_frame
      @stacks.pop
    end
  end
end
