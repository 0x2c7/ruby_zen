module RubyZen
  class MethodObject
    attr_accessor :name, :owner, :parameters, :super_method, :return_object,
                  :call_seq, :c_function, :singleton, :param_list, :return_value

    def initialize(name, owner: nil, parameters: [], super_method: nil)
      @name = name.to_sym
      @owner = owner
      @parameters = parameters
      @super_method = super_method
      @return_object = RubyZen::MaybeClassObject.new
    end

    def add_return_object(object)
      @return_object.add(object)
    end

    def merge!(other)
      @parameters = other.parameters unless other.parameters.empty?
      unless other.return_object.empty?
        if @return_object.empty?
          @return_object = other.return_object
        else
          @return_object.add(other.return_object)
        end
      end
    end

    def inpsect
      "#<MethodObject: #{name}, parameters: #{parameters.inspect}, owner: #{owner.nil? ? '<empty>' : owner.fullname}, super_method: #{super_method.nil? ? '<empty>' : super_method.inspect}>"
    end
  end
end
