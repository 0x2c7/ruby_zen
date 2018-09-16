module RubyZen
  class Frame
    attr_reader :ep, :scope

    def initialize(locals:, svar:, special:, scope:)
      @stack = []
      locals.each do |local|
        @stack.push(local)
      end
      @stack.push(svar)
      @stack.push(special)
      @ep = @stack.length - 1
      @scope = scope
      @stack.push(scope)
    end

    def push(val)
      @stack.push(val)
    end

    def pop
      @stack.pop
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

    def scope
      @frames.last.scope
    end

    def root_scope
      @frames.first.scope
    end

    def at(index, level_delta = 0)
      level = @frames.length - level_delta - 1
      return nil unless @frames[level]
      @frames[level][index]
    end

    def new_frame(locals:, svar:, special:, scope:)
      frame = RubyZen::Frame.new(
        locals: locals,
        svar: svar,
        special: special,
        scope: scope
      )
      @frames.push(frame)
    end

    def leave_frame
      @frames.pop
    end
  end
end
