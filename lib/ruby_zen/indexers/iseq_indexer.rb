module RubyZen::Indexers
  class IseqIndexer
    attr_reader :iseq

    def initialize(iseq, engine:, logger:, scope: nil, stack: [])
      @engine = engine
      @iseq = iseq
      @logger = logger

      # Fall back of scope is top binding
      @top_binding = engine.fetch_class('Object')
      @scope = scope || @top_binding
      @stack = stack
    end

    def start
      @logger.debug("Indexing iseq `#{iseq.label}`, type: `#{iseq.type}`, path: `#{iseq.path}`")

      iseq.instructions.each do |instruction|
        case instruction.name
        when 'putspecialobject'
          handle_putspecialobject(instruction)
        when 'putobject', 'putiseq'
          @stack.push(instruction.operands[0])
        when 'putnil'
          @stack.push(nil)
        when 'putself'
          @stack.push(@scope)
        when 'pop'
          @stack.pop
        when 'defineclass'
          handle_defineclass(instruction)
        when 'opt_send_without_block'
          handle_opt_send_without_block(instruction)
        when 'send'
          handle_send(instruction)
        else
          @logger.debug("Skip instruction `#{instruction.name}`")
        end
      end
    end

    private

    def start_new_iseq(new_iseq, scope: nil)
      self.class.new(
        new_iseq,
        engine: @engine, logger: @logger,
        scope: scope || @scope, stack: @stack
      ).start
    end

    def create_method_object(method_name, method_body, owner: nil)
      parameters = []

      if method_body.params[:lead_num]
        req_variables = method_body.local_table.first(method_body.params[:lead_num])
        req_variables.map do |variable|
          parameters << [:req, variable]
        end
      end

      if method_body.params[:rest_start]
        parameters << [
          :rest,
          method_body.local_table[method_body.params[:rest_start]]
        ]
      end

      if method_body.params[:keywords]
        method_body.params[:keywords].map do |variable|
          parameters << if variable.is_a?(Array)
                          [:key, variable[0], variable[1]]
                        else
                          [:keyreq, variable]
                        end
        end
      end

      if method_body.params[:kwrest]
        parameters << [
          :keyrest,
          method_body.local_table[method_body.params[:kwrest]]
        ]
      end

      RubyZen::MethodObject.new(
        method_name,
        parameters: parameters, owner: owner
      )
    end

    def handle_putspecialobject(instruction)
      case instruction.operands[0]
      when 1
        @stack.push(@top_binding)
      when 2
        @stack.push(nil)
      when 3
        @stack.push(@scope)
      else
        @stack.push(nil)
      end
    end

    def handle_defineclass(instruction)
      class_name, body, _flags = instruction.operands
      superclass = @stack.pop
      _cbase = @stack.pop

      class_object = @engine.define_class(class_name) do
        RubyZen::ClassObject.new(
          class_name, superclass: superclass
        )
      end
      start_new_iseq(body, scope: class_object)
      @stack.push(class_object)
    end

    def handle_opt_send_without_block(instruction)
      call_info, _call_cache = instruction.operands
      case call_info.mid
      when :"core#define_method", :define_method
        method_body = @stack.pop
        method_name = @stack.pop

        handle_define_method(@scope, method_name, method_body)
      when :instance_method
        method_name = @stack.pop
        receiver = @stack.pop
        @stack.push(receiver.instance_method_object(method_name))
      end
    end

    def handle_send(instruction)
      call_info, _call_cache, block_iseq = instruction.operands
      case call_info.mid
      when :define_method
        method_name = @stack.pop
        receiver = @stack.pop
        handle_define_method(receiver, method_name, block_iseq)
      end
    end

    def handle_define_method(owner, method_name, method_body)
      if method_body.is_a?(RubyZen::MethodObject)
        method_object = RubyZen::MethodObject.new(
          method_name,
          owner: owner,
          parameters: method_body.parameters,
          super_method: method_body.super_method
        )
      else
        method_object = create_method_object(method_name, method_body, owner: owner)
        start_new_iseq(method_body)
      end
      owner.add_method(method_object)
      @logger.debug("Define method `#{method_name}` of class `#{owner.fullname}`")
    end
  end
end
