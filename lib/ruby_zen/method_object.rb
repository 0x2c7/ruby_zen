module RubyZen
  class MethodObject
    # attr_reader :name, :owner, :parameters, :super_method
    attr_accessor :name, :owner, :parameters, :super_method, :call_seq, :c_function, :singleton, :visibility

    def initialize(name, owner: nil, parameters: [], super_method: nil)
      @name = name
      @owner = owner
      @parameters = parameters
      @super_method = super_method
    end

    ##
    # '::' for a class method/attribute, '#' for an instance method.

    def name_prefix
      singleton ? '::' : '#'
    end

    def arglists
      if call_seq
        call_seq
      elsif parameters
        "#{name}#{param_seq}"
      end
    end

    def inpsect
      "#<MethodObject: #{name}, parameters: #{parameters.inspect}, owner: #{owner.nil? ? '<empty>' : owner.fullname}, super_method: #{super_method.nil? ? '<empty>' : super_method.inspect}>"
    end
  end
end
