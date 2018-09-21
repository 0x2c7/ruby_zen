module RubyZen
  class Frame
    attr_reader :stack, :ep, :scope, :previous_frame

    def initialize(
      locals:, svar:, special:, scope:,
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

    def push(val)
      @frames.last.push(val)
    end

    def pop
      @frames.last.pop
    end

    def pop_n(n)
      @frames.last.pop_n(n)
    end

    def scope
      @frames.last.scope
    end

    def local(level, index)
      frame = @frames.last
      (0..level - 1).each do
        frame = frame.previous_frame
      end
      frame[frame.ep - index]
    end

    def root_scope
      @frames.first.scope
    end

    def last_frame
      @frames.last
    end

    def new_frame(locals:, svar:, special:, scope:)
      frame = RubyZen::Frame.new(
        locals: locals,
        svar: svar,
        special: special,
        scope: scope,
        previous_frame: @frames.last
      )
      @frames.push(frame)
    end

    def leave_frame
      @frames.pop
    end
  end
end
