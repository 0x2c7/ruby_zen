module RubyZen
  class Frame
    attr_reader :stack, :ep, :scope, :self_pointer, :previous_frame

    def initialize(
      locals:, svar:, special:, scope:, self_pointer:,
      previous_frame: nil
    )
      @stack = []
      locals.each do |local|
        @stack.push(local)
      end
      @stack.push(svar)
      @stack.push(special)
      @ep = @stack.length - 1
      @scope = scope
      @self_pointer = self_pointer
      @stack.push(scope)
      @previous_frame = previous_frame
    end

    def push(val)
      @stack.push(val)
    end

    def pop
      @stack.pop
    end

    def pop_n(n)
      @stack.slice!(@stack.length - n, n)
    end

    def [](index)
      @stack[index]
    end
  end

  class FrameStack
    def initialize
      @frames = []
    end

    def last_frame
      @frames.last
    end

    def push(val)
      last_frame.push(val)
    end

    def pop
      last_frame.pop
    end

    def pop_n(n)
      last_frame.pop_n(n)
    end

    def scope
      last_frame.scope
    end

    def local(level, index)
      frame = last_frame
      (0..level - 1).each do
        frame = frame.previous_frame
      end
      frame[frame.ep - index]
    end

    def root_scope
      @frames.first.scope
    end

    def self_pointer
      last_frame.self_pointer
    end

    def new_frame(locals:, svar:, special:, scope:, self_pointer:)
      frame = RubyZen::Frame.new(
        locals: locals,
        svar: svar,
        special: special,
        scope: scope,
        self_pointer: self_pointer,
        previous_frame: last_frame
      )
      @frames.push(frame)
    end

    def leave_frame
      @frames.pop
    end
  end
end
