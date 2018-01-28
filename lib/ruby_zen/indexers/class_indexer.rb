module RubyZen::Indexers
  class ClassIndexer
    attr_reader :klass

    SINGLETON_CLASS_PATTERN = /^\#\<Class\:([^\>]+)\>$/

    def initialize(engine, klass, logger:)
      @engine = engine
      @klass = klass
      @logger = logger
    end

    def start
      class_object = define_class(klass)

      klass.instance_methods.each do |method_name|
        method_object = define_method_object(klass.instance_method(method_name))
        class_object.add_method(method_object)
      end

      klass.methods.each do |method_name|
        method_object = define_method_object(klass.method(method_name))
        class_object.add_class_method(method_object)
      end

      @logger.debug("Finish indexing #{klass}")
    end

    private

    def define_class(klass)
      if klass.nil?
        nil
      elsif klass.name.nil?
        # Singleton class
        define_singleton_class(klass)
      elsif !klass.respond_to?(:superclass)
        # Module
        @engine.define_class(klass.name) do
          RubyZen::ClassObject.new(klass.name, is_module: true)
        end
      else
        # Normal class
        @engine.define_class(klass.name) do
          RubyZen::ClassObject.new(
            klass.name, superclass: define_class(klass.superclass)
          )
        end
      end
    end

    def define_singleton_class(klass)
      match = SINGLETON_CLASS_PATTERN.match(klass.to_s)
      return nil unless match
      original_klass = Object.const_get(match[1])

      @engine.define_class(original_klass.name) do
        RubyZen::ClassObject.new(
          original_klass.name,
          superclass: define_class(original_klass.superclass)
        )
      end.singleton_class
    end

    def define_method_object(native_method)
      return nil if native_method.nil?

      RubyZen::MethodObject.new(
        native_method.name,
        owner: define_class(native_method.owner),
        super_method: define_method_object(native_method.super_method),
        parameters: native_method.parameters
      )
    end
  end
end
