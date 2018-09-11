module RubyZen::Indexers
  class RubyCoreIndexer
    require 'rdoc/rdoc'

    VISIBILITY = %i[private protected].freeze
    INSTANTIATION_METHODS = %w[new [] {}].freeze
    SIZE_METHODS = %w[size length].freeze
    COMPARISON_METHODS = %w[== === > < <= >=].freeze

    def initialize(filename, engine:, logger:)
      @filename = filename
      @engine = engine
      @logger = logger
    end

    def start
      rdoc = RDoc::RDoc.new
      rdoc.options = options
      rdoc.store = store

      parsed_internal_ruby = rdoc.parse_files([@filename])
      index_internal(parsed_internal_ruby)
    end

    def options
      @options ||= RDoc::Options.new
    end

    def store
      @store = RDoc::Store.new

      @store.encoding = options.encoding
      @store.dry_run  = options.dry_run
      @store.main     = options.main_page
      @store.title    = options.title
      @store.path     = options.op_dir

      @store
    end

    def numeric?(str)
      Float(str) != nil rescue false
    end

    def index_internal(ruby)
      ruby.each do |file|
        index_containers(file.classes)
        index_containers(file.modules)
      end
    end

    def index_containers(containers)
      containers.each do |container|
        class_object = define_class_object(container)
        container.method_list.each do |method|
          next if VISIBILITY.include?(method.visibility)
          method_object = define_method_object(method, class_object)
          if method.singleton
            class_object.add_class_method(method_object)
          else
            class_object.add_method(method_object)
          end
        end
      end
    end

    def define_class_object(container)
      superclass = container.module? ? nil : container.superclass

      if superclass
        name = superclass.is_a?(String) ? superclass : superclass.full_name
        superclass = @engine.define_class(name) do
          RubyZen::ClassObject.new(name)
        end
      end

      class_object = @engine.define_class(container.full_name) do
        RubyZen::ClassObject.new(
          container.full_name,
          superclass: superclass,
          is_module: container.module?
        )
      end

      container.includes.each do |mod|
        module_object = @engine.fetch_class(mod.name)
        class_object.include_module(module_object) if module_object
      end

      container.extends.each do |mod|
        module_object = @engine.fetch_class(mod.name)
        class_object.extend_module(module_object) if module_object
      end

      class_object.visibility = container.visibility
      class_object
    end

    def define_method_object(method, klass)
      if method.is_alias_for
        method_object = if method.singleton
                          klass.class_method_object(method.name)
                        else
                          klass.instance_method_object(method.name)
                        end
        if method_object
          method_object = method_object.clone
          method_object.name = method.name
          return method_object
        end
      end

      method_object = RubyZen::MethodObject.new(method.name, owner: klass)

      method_object.c_function = method.c_function
      method_object.call_seq = method.call_seq
      method_object.param_list = method.param_list
      method_object.super_method = method.superclass_method

      index_return_value(method_object)

      method_object
    end

    def index_return_value(method)
      return_objects = []
      return_value = []

      if INSTANTIATION_METHODS.include?(method.name)
        return_objects << method.owner
      elsif SIZE_METHODS.include?(method.name)
        return_objects << @engine.fetch_class('Integer')
      elsif method.name.end_with?('?') || COMPARISON_METHODS.include?(method.name)
        return_objects << @engine.fetch_class('TrueClass')
        return_objects << @engine.fetch_class('FalseClass')
      elsif method.name == 'json_create'
        return_objects << method.owner
      elsif method.name == 'as_json'
        return_objects << @engine.fetch_class('Hash')
      elsif method.call_seq
        if method.call_seq =~ /->/
          method.call_seq.split("\n").each do |line|
            if line[/(?<=->\s).*/]
              return_value << parse_call_seq(line[/(?<=->\s).*/])
            else
              return_objects << @engine.fetch_class('Object')
            end
          end
          return_objects += parse_return_value(method, return_value.flatten.uniq)
        elsif method.call_seq =~ /=>/
          method.call_seq.split("\n").each do |line|
            if line[/(?<==>\s).*/]
              return_value << parse_call_seq(line[/(?<==>\s).*/])
            else
              return_objects << @engine.fetch_class('Object')
            end
          end
          return_objects += parse_return_value(method, return_value.flatten.uniq)
        elsif method.call_seq =~ /(?<==\s)[^\)]*$/
          method.call_seq.split("\n").each do |line|
            if line[/(?<==\s)[^\)]*$/]
              return_value << parse_call_seq(line[/(?<==\s)[^\)]*$/])
            else
              return_objects << @engine.fetch_class('Object')
            end
          end
          return_objects += parse_return_value(method, return_value.flatten.uniq)
        elsif method.call_seq =~ /to_/
          return_objects = parse_transform_method(method.name[/(?<=_).*/])
        elsif method.name =~ /exit|abort/
          return_objects << @engine.fetch_class('Object')
        else
          return_objects << @engine.fetch_class('Object')
        end
      elsif method.name =~ /to_/
        return_objects = parse_transform_method(method.name[/(?<=_).*/])
      elsif method.name =~ /exit|abort/
        return_objects << @engine.fetch_class('Object')
      else
        return_objects << @engine.fetch_class('Object')
      end

      return_objects.each do |return_object|
        method.add_return_object(return_object)
      end
    end

    def parse_transform_method(datatype)
      return_object = []

      if %w[s string].include?(datatype)
        return_object << @engine.fetch_class('String')
      elsif %w[a].include?(datatype)
        return_object << @engine.fetch_class('Array')
      elsif %w[i int bn].include?(datatype)
        return_object << @engine.fetch_class('Integer')
      elsif %w[json].include?(datatype)
        return_object << @engine.fetch_class('JSON')
      elsif %w[f].include?(datatype)
        return_object << @engine.fetch_class('Float')
      elsif %w[r].include?(datatype)
        return_object << @engine.fetch_class('Rational')
      elsif %w[h].include?(datatype)
        return_object << @engine.fetch_class('Hash')
      elsif %w[proc].include?(datatype)
        return_object << @engine.fetch_class('Proc')
      elsif %w[set].include?(datatype)
        return_object << @engine.fetch_class('Set')
      elsif %w[matrix].include?(datatype)
        return_object << @engine.fetch_class('Matrix')
      else
        return_object << @engine.fetch_class('Object')
      end

      return_object
    end

    def parse_call_seq(line)
      line.sub!(/".*"/, 'str')
      line.sub!(/'.*'/, 'str')
      line.sub!(/\[.*\]|^\[.*,/, 'ary')
      line.sub!(/{.*}|^{.*,/, 'hash')

      line.split(' ')
    end

    def parse_return_value(method, value_list)
      list = []
      self_instance = method.owner

      value_list.each do |value|
        next if value == 'or' || value == '|'

        value.chomp!(',')
        value.downcase!

        if value[/ary|array/]
          list << @engine.fetch_class('Array')
        elsif value[/stringscanner/]
          list << @engine.fetch_class('StringScanner')
        elsif value[/strio/]
          list << @engine.fetch_class('StringIO')
        elsif value[/string|str|char/]
          list << @engine.fetch_class('String')
        elsif value[/nil/]
          list << @engine.fetch_class('NilClass')
        elsif value[/int|fixnum/]
          list << @engine.fetch_class('Integer')
        elsif value[/enumerator/]
          list << @engine.fetch_class('Enumerator')
        elsif value[/true|false|bool/]
          list << @engine.fetch_class('TrueClass')
          list << @engine.fetch_class('FalseClass')
        elsif value[/hash|hsh/]
          list << @engine.fetch_class('Hash')
        elsif value[/proc/]
          list << @engine.fetch_class('Proc')
        elsif value[/enc/]
          list << @engine.fetch_class('Encoding')
        elsif value[/num|real/] || numeric?(value)
          list << @engine.fetch_class('Numeric')
        elsif value[/float/]
          list << @engine.fetch_class('Float')
        elsif value[/bigdecimal|big_decimal/]
          list << @engine.fetch_class('BigDecimal')
        elsif value[/class/]
          list << @engine.fetch_class('Class')
        elsif value[/mod/]
          list << @engine.fetch_class('Module')
        elsif value[/time/]
          list << @engine.fetch_class('Time')
        elsif value[/date/]
          list << @engine.fetch_class('Date')
        elsif value[/io/]
          list << @engine.fetch_class('IO')
        elsif value[/file/]
          list << @engine.fetch_class('File')
        elsif value[/sym/]
          list << @engine.fetch_class('Symbol')
        elsif value[/thread|thr/]
          list << @engine.fetch_class('Thread')
        elsif value[/thgrp/]
          list << @engine.fetch_class('ThreadGroup')
        elsif value[/rational|(0\/1)/]
          list << @engine.fetch_class('Rational')
        elsif value[/complex|.*+.*i/]
          list << @engine.fetch_class('Complex')
        elsif value[/ostruct|openstruct/]
          list << @engine.fetch_class('OpenStruct')
        elsif value[/struct/]
          list << @engine.fetch_class('Struct')
        elsif value[/set/]
          list << @engine.fetch_class('Set')
        elsif value[/pathname/]
          list << @engine.fetch_class('Pathname')
        elsif value[/dir/]
          list << @engine.fetch_class('Dir')
        elsif value[/matchdata/]
          list << @engine.fetch_class('MatchData')
        elsif value[/basicsocket/]
          list << @engine.fetch_class('BasicSocket')
        elsif value[/addrinfo/]
          list << @engine.fetch_class('Addrinfo')
        elsif value[/exception/]
          list << @engine.fetch_class('Exception')
        elsif value[/regexp/]
          list << @engine.fetch_class('Regexp')
        elsif value[/method/]
          list << @engine.fetch_class('Method')
        elsif value[/rng/]
          list << @engine.fetch_class('Range')
        elsif value[/gdbm/]
          list << @engine.fetch_class('GDBM')
        elsif value[/system_exit/]
          list << @engine.fetch_class('SystemExit')
        elsif value[/name_error/]
          list << @engine.fetch_class('NameError')
        elsif value[/no_method_error/]
          list << @engine.fetch_class('NoMethodError')
        elsif value[/key_error/]
          list << @engine.fetch_class('KeyError')
        elsif value[/syntax_error/]
          list << @engine.fetch_class('SyntaxError')
        elsif value[/system_call_error/]
          list << @engine.fetch_class('SystemCallError')
        elsif value[/argf/]
          list << @engine.fetch_class('ARGF')
        elsif value[/uri/]
          list << @engine.fetch_class('URI')
        elsif value[/psychj/]
          list << @engine.fetch_class('Psych')
        elsif value[/self/]
          list << self_instance
        else
          list << @engine.fetch_class('Object')
        end
      end

      list
    end
  end
end
