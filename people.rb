require_relative "person"
require "singleton"


class People

    # Attributes
    # ------------------
    # :db: Database where all people are stored.
    #
    # Methods
    # ------------------
    # :add: Add a new person to the database.
    # :get: Get Person by name.
    # :toString: Convert People to string.

    include Singleton

    def initialize()
        @db = {}
    end

    def add(person)
        raise ArgumentError, "Invalid Person" unless person.instance_of? Person
        @db[person.name] = person
    end

    def get(name)
        if not @db.key?(name)
            @db[name] = Person.new(name)
        end
        return @db[name]
    end

    def toString()
        s = ""
        s.concat("People\n")
        s.concat("-----------------------------\n")
        @db.each do |name, person|
            s.concat(person.toString())
        end
        s.concat("\n")
        return s
    end

end

if __FILE__ == $0
    p1 = People.instance.get("martin")
    p2 = People.instance.get("castro")
    People.instance.add(p1)
    People.instance.add(p2)
    puts People.instance.get("martin").toString()
    puts People.instance.toString()
end
