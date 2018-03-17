module Hello
  class World
    def test(a, b)
      puts a
      puts b
    end

    class Greet
      def say_hello
      end
    end
  end
end

class Hello::World::Greet
  def say_bye
  end
end

class Hello::World
  class Meeting
    def discuss
    end
  end
end
