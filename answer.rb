require_relative "people"
require_relative "person"


class Answer

    # Attributes
    # ------------------
    # :message: Human text answer message.
    # :person: Teacher name.
    # :feedback: Amount of times this answer received feedback.
    # :weight: Answer weight over time.
    #
    # Methods
    # ------------------
    # :sendFeedback: Encourage or discourage using this answer in the future.
    # :toString: Convert Answer to string.
    # :getWeight: Get answer real weight.
    # :getPerson: Get teacher Person object.

    attr_reader :message

    def initialize(message, person)
        raise ArgumentError, "Invalid Person" unless person.instance_of? Person
        @message = message
        @person = person.name
        @feedback = 1
        @weight = person.getInfluence()

    end

    def sendFeedback(person, connotation=0)
        raise ArgumentError, "Invalid Person" unless person.instance_of? Person
        @feedback *= 1.1
        if connotation >= 0
            @weight *= 1.0 + (0.1 + connotation * person.getInfluence())
        else
            @weight /= 1.0 + (0.5 + connotation.abs * person.getInfluence())
        end
    end

    def getWeight()
        return @weight * getPerson().getInfluence() * @feedback / 100
    end

    def getPerson()
        return People.instance.get(@person)
    end

    def toString()
        return "'#{@message}' [weight=#{getWeight()}] [teacher=#{@person}]\n"
    end

end

if __FILE__ == $0
    p = People.instance.get("martin")
    a = Answer.new("Hi, this is my answer!!", p)
    puts a.toString()
    a.sendFeedback(p, 0.5)
    puts a.toString()
    a.sendFeedback(p, -0.5)
    puts a.toString()
end
