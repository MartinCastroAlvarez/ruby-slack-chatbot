require_relative "people"
require_relative "person"


class Answer

    # Attributes
    # ------------------
    # :message: Human text answer message.
    # :type: Type of answer.
    # :person: Person who taught this answer.
    # :feedback: Amount of times this answer received feedback.
    # :weight: Answer weight over time.
    #
    # Methods
    # ------------------
    # :sendFeedback: Encourage or discourage using this answer in the future.
    # :toString: Convert Answer to string.
    # :getWeight: Get answer real weight.
    # :getPerson: Get teacher Person object.
    # 
    # Static Attributes
    # ------------------
    # :SIMPLE_ANSWER: Simple answer code to a simple question.


    @@SIMPLE_ANSWER = "simple_answer"

    attr_reader :message
    attr_reader :type

    def initialize(message, person, type=@@SIMPLE_ANSWER)
        raise ArgumentError, "Invalid Person" unless person.instance_of? Person
        @person = person.name
        @message = message
        @type = type
        @feedback = 1
        @weight = getPerson().getInfluence()

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
        return "'#{@message}' [#{@type}] [weight=#{getWeight()}] [teacher=#{@person}]\n"
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
