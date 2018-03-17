class Order
  def calculate(a, b)
    puts a
    puts b
  end

  def finish(date, failed = false)
    puts date
    puts failed
  end

  def delete(permanent = false)
    puts permanent
  end

  def add(*items)
    puts items
  end

  def config(config_a: 1, config_b: 2, config_c:)
    puts config_a
    puts config_b
    puts config_c
  end

  def save(**metadata)
    puts metadata
  end

  def total(a, b, *c, d: 1, e: 2, &block)
    puts a
    puts b
    puts c
    puts d
    puts e
    block.call
  end

  define_method :upload do |a, b|
    puts a
    puts b
  end

  define_method :total_2, instance_method(:total)

  private

  def private_calculate(a, b)
    puts a, b
  end

  define_method :private_calculate_2 do |a, b|
    puts a, b
  end
end
