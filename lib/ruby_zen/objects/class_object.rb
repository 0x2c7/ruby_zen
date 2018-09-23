module RubyZen
  class ClassObject
    attr_reader :name, :fullname, :is_singleton, :singleton_class,
                :included_modules, :extended_modules, :prepended_modules
    attr_accessor :is_module, :superclass, :namespace, :visibility

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

    def instance_method(method_id)
      instance_methods[method_id]
    end

    def instance_methods
      methods = superclass.nil? ? {} : superclass.instance_methods

      @included_modules.each do |_module_name, module_definition|
        methods.merge!(module_definition.instance_methods)
      end

      methods.merge!(@method_objects)

      @prepended_modules.each do |_module_name, module_definition|
        methods.merge!(module_definition.instance_methods)
      end

      methods
    end

    def class_method(method_id)
      class_methods[method_id]
    end

    def class_methods(as_module = false)
      methods = superclass.nil? ? {} : superclass.class_methods

      if is_module && !as_module
        methods.merge!(instance_methods)
      else
        @extended_modules.each do |_module_name, module_definition|
          methods.merge!(module_definition.instance_methods)
        end
      end

      methods.merge!(singleton_class.instance_methods)
    end

    def add_method(method_object)
      if @method_objects[method_object.name]
        @method_objects[method_object.name].merge!(method_object)
      else
        @method_objects[method_object.name] = method_object
      end
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
