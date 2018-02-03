class Contract
  def self.clone(source)
    puts source
  end

  class << self
    def copy(source)
      puts source
    end

    define_method(:compare) do |other|
      puts other
    end
    define_method :copy_2, Contract.method(:copy)
    define_method :copy_3, Contract.method(:copy).to_proc
    define_method :copy_4, instance_method(:copy)
  end

  define_singleton_method(:test) do |a|
    puts a
  end
end

class << Contract
  def build(data)
    puts data
  end
end

def Contract.seal(key)
  puts key
end
