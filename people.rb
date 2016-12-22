

class Person

    @@db = {}

    # Classmethod
    def self.get(person)
        # Get (or create) one person from database.
        if not @@db.key?(person)
            @@db[person] = Person(person)
        end
        return @@db[person]
    end

    # Classmethod
    def self.getAverageFamiliarity()
        # Get average familiarity for all people.
        total = 0.0
        count = 0.0
        @@db.each do |name, person|
            total += person.familiarity
            count += 1.0
        end
        if count > 0
            return total / count
        else
            return 0
        end
    end

    # Classmethod
    def self.getAverageAffinity()
        # Get average affinity for all people.
        total = 0.0
        count = 0.0
        @@db.each do |name, person|
            total += person.affinity
            count += 1.0
        end
        if count > 0
            return total / count
        else
            return 0.0
        end
    end

    attr_reader :name
    attr_reader :familiarity
    attr_reader :affinity

    def initialize(name)
        @name = name  # Name of this person
        @familiarity = 1.0  # Familiarity with this person. Always positive.
        @affinity = 1.0  # Affinity with this person. If more than 1, likes this person.
        @@db[name] = self
    end

    def interact(connotation=0)
        # Know this person a bit more.
        @familiarity *= 1.1
        if connotation >= 0 and connotation <= 1
            @affinity *= 1.0 + (0.1 + connotation)
        elsif connotation <= 0 and connotation >= -1
            @affinity /= 1.0 + (0.5 + connotation.abs)
        end
    end

    def getInfluence()
        # Gets influence with this person.
        return @familiarity * @affinity / (Person.getAverageFamiliarity() * Person.getAverageAffinity())
    end

    def toString()
        # Print Person as string.
        return "#{@name} [#{@affinity} * #{@familiarity} = #{getInfluence()}]"
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
    puts Person.get("martin").toString()
    Person.get("martin").interact(-0.5)
    puts p1.toString()
end
