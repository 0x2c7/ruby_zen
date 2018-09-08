module RubyZen
  class ClassObject
    attr_reader :name, :fullname, :is_singleton, :singleton_class,
                :included_modules, :extended_modules, :prepended_modules
    attr_accessor :is_module, :superclass, :namespace

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

    def method_list
      @method_objects
    end

    def instance_method_object(method_id)
      instance_method_objects[method_id]
    end

    def instance_method_objects
      methods = superclass.nil? ? {} : superclass.instance_method_objects

      @included_modules.each do |_module_name, module_definition|
        methods.merge!(module_definition.instance_method_objects)
      end

      methods.merge!(@method_objects)

      @prepended_modules.each do |_module_name, module_definition|
        methods.merge!(module_definition.instance_method_objects)
      end

      methods
    end

    def class_method_object(method_id)
      class_method_objects[method_id]
    end

    def class_method_objects(as_module = false)
      methods = superclass.nil? ? {} : superclass.class_method_objects

      if is_module && !as_module
        methods.merge!(instance_method_objects)
      else
        @extended_modules.each do |_module_name, module_definition|
          methods.merge!(module_definition.instance_method_objects)
        end
      end

      methods.merge!(singleton_class.instance_method_objects)
    end

    def add_method(method_object)
      @method_objects[method_object.name] = method_object
    end

    def add_class_method(method_object)
      singleton_class.add_method(method_object) unless singleton_class.nil?
    end

    def add_method_return_object(method_id, object)
      @method_objects[method_id].add_return_object(object)
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
