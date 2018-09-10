module RubyZen
  class MethodObject
    attr_accessor :name, :owner, :parameters, :super_method, :return_object,
                  :call_seq, :c_function, :singleton, :param_list, :return_value

    def initialize(name, owner: nil, parameters: [], super_method: nil)
      @name = name
      @owner = owner
      @parameters = parameters
      @super_method = super_method
      @return_object = RubyZen::ReturnObject.new(self)
    end

    def add_return_object(object)
      @return_object.add(object)
    end

    def inpsect
      "#<MethodObject: #{name}, parameters: #{parameters.inspect}, owner: #{owner.nil? ? '<empty>' : owner.fullname}, super_method: #{super_method.nil? ? '<empty>' : super_method.inspect}>"
    end
  end
end
