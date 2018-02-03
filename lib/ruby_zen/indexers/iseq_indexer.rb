module RubyZen::Indexers
  class IseqIndexer
    attr_reader :iseq

    def initialize(iseq, engine:, logger:)
      @engine = engine
      @iseq = iseq
      @logger = logger
      @vm = RubyZen::VM.new(
        scope: engine.fetch_class('Object'),
        logger: logger
      )
      register_processors
    end

    def start
      @vm.run(iseq)
    end

    def register_processors
      @vm.register_processor('defineclass') do |name, _body, superclass, cbase|
        if name == :singletonclass
          cbase.singleton_class
        else
          @engine.define_class(name) do
            RubyZen::ClassObject.new(name, superclass: superclass)
          end
        end
      end

      @vm.register_processor('getconstant') do |constant_name|
        @engine.fetch_class(constant_name)
      end

      @vm.register_processor('opt_send_without_block', 'define_method') do |receiver, method_name, method_body|
        define_instance_method(receiver, method_name, method_body)
      end

      @vm.register_processor('opt_send_without_block', 'instance_method') do |receiver, method_name|
        receiver.instance_method_object(method_name)
      end

      @vm.register_processor('opt_send_without_block', 'method') do |receiver, method_name|
        receiver.class_method_object(method_name)
      end

      @vm.register_processor('send', 'define_method') do |receiver, method_name, method_body|
        define_instance_method(receiver, method_name, method_body)
      end

      @vm.register_processor('send', 'define_singleton_method') do |receiver, method_name, method_body|
        define_class_method(receiver, method_name, method_body)
      end
    end

    private

    def define_instance_method(receiver, method_name, method_body, singleton: false)
      if method_body.is_a?(RubyZen::MethodObject)
        method_object = RubyZen::MethodObject.new(
          method_name,
          owner: receiver,
          parameters: method_body.parameters,
          super_method: method_body.super_method
        )
      else
        method_object = create_method_object(method_name, method_body, owner: receiver)
      end
      receiver.add_method(method_object)

      @logger.info("Detect instance method `#{method_name}` of class `#{receiver.to_s}`")
    end

    def define_class_method(receiver, method_name, method_body)
      if method_body.is_a?(RubyZen::MethodObject)
        method_object = RubyZen::MethodObject.new(
          method_name,
          owner: receiver.singleton_class,
          parameters: method_body.parameters,
          super_method: method_body.super_method
        )
      else
        method_object = create_method_object(method_name, method_body, owner: receiver.singleton_class)
      end
      receiver.add_class_method(method_object)

      @logger.info("Detect class method `#{method_name}` of class `#{receiver.to_s}`")
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
