module RubyZen
  class MethodObject
    # attr_reader :name, :owner, :parameters, :super_method
    attr_accessor :name, :owner, :parameters, :super_method,
                  :call_seq, :c_function, :singleton, :visibility, :block_params

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

    def param_seq
      if @call_seq
        params = @call_seq.split("\n").last
        params = params.sub(/[^( ]+/, '')
        params = params.sub(/(\|[^|]+\|)\s*\.\.\.\s*(end|\})/, '\1 \2')
      elsif @parameters
        params = @params.gsub(/\s*\#.*/, '')
        params = params.tr_s("\n ", " ")
        params = "(#{params})" unless params[0] == ?(
      else
        params = ''
      end

      if @block_params
        # If this method has explicit block parameters, remove any explicit
        # &block
        params = params.sub(/,?\s*&\w+/, '')

        block = @block_params.tr_s("\n ", " ")
        if block[0] == ?(
          block = block.sub(/^\(/, '').sub(/\)/, '')
        end
        params << " { |#{block}| ... }"
      end

      params
    end

    def param_list
      if @call_seq
        params = @call_seq.split("\n").last
        params = params.sub(/.*?\((.*)\)/, '\1')
        params = params.sub(/(\{|do)\s*\|([^|]*)\|.*/, ',\2')
      elsif @parameterss
        params = @params.sub(/\((.*)\)/, '\1')

        params << ",#{@block_params}" if @block_params
      elsif @block_params
        params = @block_params
      else
        return []
      end

      if @block_params then
        # If this method has explicit block parameters, remove any explicit
        # &block
        params = params.sub(/,?\s*&\w+/, '')
      else
        params = params.sub(/\&(\w+)/, '\1')
      end

      params = params.gsub(/\s+/, '').split(',').reject(&:empty?)

      params.map { |param| param.sub(/=.*/, '') }
    end

    def inpsect
      "#<MethodObject: #{name}, parameters: #{parameters.inspect}, owner: #{owner.nil? ? '<empty>' : owner.fullname}, super_method: #{super_method.nil? ? '<empty>' : super_method.inspect}>"
    end
  end
end
