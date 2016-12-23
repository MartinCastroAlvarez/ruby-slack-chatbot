

class Person

    # Methods
    # ------------------
    # :name: Name of this person.
    # :familiarity: Familiarity with this person.
    # :affinity: Affinity with this person.
    #
    # Attributes
    # ------------------
    # :interact: Like or Hate this person a bit more.
    # :getInfluence: Get Person influence from 0 to infinte+.
    # :toString: Convert Person to string.

    attr_reader :name
    attr_reader :familiarity
    attr_reader :affinity

    def initialize(name)
        @name = name
        @familiarity = 1.0
        @affinity = 1.0
    end

    def interact(connotation=0)
        @familiarity *= 1.1
        if connotation >= 0 and connotation <= 1
            @affinity *= 1.0 + (0.1 + connotation)
        elsif connotation <= 0 and connotation >= -1
            @affinity /= 1.0 + (0.5 + connotation.abs)
        end
    end

    def getInfluence()
        return @familiarity * @affinity
    end

    def toString()
        return "#{@name} [#{@affinity} * #{@familiarity} = #{getInfluence()}]\n"
    end

end

if __FILE__ == $0
    p1 = Person.new("martin")
    puts p1.toString()
    p1.interact(0.9)
    puts p1.toString()
    p2 = Person.new("alejandro")
    p2.interact(0.3)
    p2.interact(1)
    puts p2.toString()
end
