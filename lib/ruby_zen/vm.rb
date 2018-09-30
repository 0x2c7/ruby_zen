module RubyZen
  class VM
    attr_reader :engine, :environment

    NIL_CLASS = 'NilClass'.freeze

    def initialize(engine:, logger:, interpreter_registry:)
      @engine = engine

      @environment = RubyZen::FrameStack.new
      @logger = logger
      @interpreter_registry = interpreter_registry
    end

    def run(iseq, scope = nil)
      @logger.info("Indexing iseq `#{iseq.label}`, type: `#{iseq.type}`, path: `#{iseq.path}`")

      # Push new frame
      @environment.new_frame(
        locals: iseq.local_table.map do |_variable|
          RubyZen::MaybeObject.new(
            [engine.define_class(NIL_CLASS)&.instance]
          )
        end,
        svar: nil,
        special: nil,
        scope: scope
      )

      # Run through the instructions
      iseq.instructions.each do |instruction|
        interpreter = @interpreter_registry.interpreter_for(instruction.name)
        if interpreter.nil?
          @logger.debug("Skip instruction `#{instruction.name}`")
        else
          @logger.debug("Interpreting #{instruction.name}(#{instruction.operands})")
          interpreter.call(self, instruction)
        end
      end

      @environment.leave_frame
    end

    def define_instance_method(receiver, method_name, method_body)
      method_object =
        if method_body.is_a?(RubyZen::MethodObject)
          RubyZen::MethodObject.new(
            method_name,
            owner: receiver,
            parameters: method_body.parameters,
            super_method: method_body.super_method
          )
        else
          create_method_object(method_name, method_body, owner: receiver)
        end
      receiver.add_method(method_object)

      @logger.info("Detect instance method `#{method_name}` of class `#{receiver}`")
      method_object
    end

    def define_class_method(receiver, method_name, method_body)
      method_object =
        if method_body.is_a?(RubyZen::MethodObject)
          RubyZen::MethodObject.new(
            method_name,
            owner: receiver.singleton_class,
            parameters: method_body.parameters,
            super_method: method_body.super_method
          )
        else
          create_method_object(method_name, method_body, owner: receiver.singleton_class)
        end
      receiver.add_class_method(method_object)

      @logger.info("Detect class method `#{method_name}` of class `#{receiver}`")
    end

    def create_method_object(method_name, method_body, owner: nil)
      parameters = []

      if method_body.params[:lead_num]
        req_variables = method_body.local_table.first(method_body.params[:lead_num])
        req_variables.map do |variable|
          parameters << [:req, variable]
        end
      end

      if method_body.params[:opt]
        lead_num = method_body.params[:lead_num] || 0
        method_body.params[:opt].each_with_index do |opt, index|
          parameters << [:opt, method_body.local_table[lead_num + index], opt]
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
  end
end
