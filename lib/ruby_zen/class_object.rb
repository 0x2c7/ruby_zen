module RubyZen
  class ClassObject
    attr_reader :name, :fullname, :is_singleton, :is_module,
                :superclass, :singleton_class


    def initialize(fullname, is_module: false, is_singleton: false, superclass: nil)
      @fullname = fullname.to_s
      @name = @fullname.split('::').last

      @is_module = is_module
      @is_singleton = is_singleton
      @superclass = superclass
      @method_objects = {}

      unless is_singleton
        @singleton_class = RubyZen::ClassObject.new(
          fullname, is_singleton: true
        )
      end
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

    def class_method_objects(inherited = true)
      return [] if singleton_class.nil?
      singleton_class.instance_method_objects(inherited)
    end

    def add_method(method_object)
      @method_objects[method_object.name] = method_object
    end

    def add_class_method(method_object)
      singleton_class.add_method(method_object)
    end

    def inspect
      "#<ClassObject: #{fullname}, is_module: #{is_module}, is_singleton: #{is_singleton}, singleton_class: #{singleton_class.inspect}, superclass: #{superclass.nil? ? '<empty>' : superclass.name}>"
    end
  end
end
