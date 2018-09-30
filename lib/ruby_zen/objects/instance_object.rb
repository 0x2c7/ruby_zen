module RubyZen
  class InstanceObject
    attr_reader :class_object

    def initialize(class_object)
      @class_object = class_object
    end

    def methods
      class_object.instance_methods
    end

    def method(method_id)
      class_object.instance_method(method_id)
    end
  end
end
