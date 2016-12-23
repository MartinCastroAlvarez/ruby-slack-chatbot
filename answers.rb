require_relative "people"


class Answer

    # Attributes
    # ------------------
    # :text: Human text answer message.
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

    attr_reader :text
    attr_reader :type

    def initialize(text, person, type=@@SIMPLE_ANSWER)
        raise ArgumentError, "Invalid Person" unless person.instance_of? Person
        @person = person.name
        @text = text
        @type = type
        @feedback = 1
        @weight = getPerson().getInfluence()

    end

    def sendFeedback(person, connotation=0)
        raise ArgumentError, "Invalid Person" unless person.instance_of? Person
        @feedback *= 1.1
        if connotation >= 0 and connotation <= 1
            @weight *= 1.0 + (0.1 + connotation * person.getInfluence())
        elsif connotation <= 0 and connotation >= -1
            @weight /= 1.0 + (0.5 + connotation.abs * person.getInfluence())

        end
    end

    def getWeight()
        return @weight * getPerson().getInfluence() * @feedback / 100
    end

    def getPerson()
        return Person.get(@person)
    end

end

if __FILE__ == $0
    p = Person.new("martin")
    a = Answer.new("Hi, this is my answer!!", p)
    puts a.getWeight()
    a.sendFeedback(p, 0.5)
    puts a.getWeight()
    a.sendFeedback(p, -0.5)
    puts a.getWeight()
end
