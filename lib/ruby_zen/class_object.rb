module RubyZen
  class ClassObject
    attr_reader :name, :fullname, :is_singleton, :is_module,
                :superclass, :singleton_class, :namespace,
                :included_modules, :extended_modules, :prepended_modules


    def initialize(fullname, is_module: false, is_singleton: false, superclass: nil, namespace: nil)
      @fullname = fullname.to_s
      @name = @fullname.split('::').last

      @is_module = is_module
      @is_singleton = is_singleton
      @superclass = superclass
      @namespace = namespace
      @method_objects = {}
      @included_modules = {}
      @extended_modules = {}
      @prepended_modules = {}

      unless is_singleton
        @singleton_class = RubyZen::ClassObject.new(
          fullname, is_singleton: true
        )
      end
    end

    def instance_method_object(method_id)
      @method_objects[method_id]
    end

    def instance_method_objects(inherited = true)
      if inherited
        @method_objects.values
      else
        @method_objects.values.select do |method_object|
          method_object.owner == self
        end
      end
    end

    def available_instance_methods
      methods = superclass.available_instance_methods unless superclass.nil?

      @included_modules.each do |included_module|
        methods.merge!(included_module.available_instance_methods)
      end

      methods.merge!(@method_objects)

      @prepended_modules.each do |prepended_module|
        methods.merge!(prepended_module.available_instance_methods)
      end

      methods
    end

    def class_method_object(method_id)
      return nil if singleton_class.nil?
      singleton_class.instance_method_object(method_id)
    end

    def class_method_objects(inherited = true)
      return [] if singleton_class.nil?
      singleton_class.instance_method_objects(inherited)
    end

    def add_method(method_object)
      @method_objects[method_object.name] = method_object
    end

    def add_class_method(method_object)
      singleton_class.add_method(method_object) unless singleton_class.nil?
    end

    def include_module(module_definition)
      @included_modules[module_definition.name] = module_definition
    end

    def extend_module(module_definition)
      @extended_modules[module_definition.name] = module_definition
    end

    def prepend_module(module_definition)
      @prepended_modules[module_definition.name] = module_definition
    end

    def inspect
      "#<ClassObject: #{fullname}, is_module: #{is_module}, is_singleton: #{is_singleton}, singleton_class: #{singleton_class.inspect}, superclass: #{superclass.nil? ? '<empty>' : superclass.name}>"
    end

    def to_s
      "#<ClassObject: #{fullname}#{is_singleton ? '(singleton)' : ''}>"
    end
  end
end
