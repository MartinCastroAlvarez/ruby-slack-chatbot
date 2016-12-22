require_relative "people"


class Answer

    @@SIMPLE_ANSWER = "simple_answer"

    attr_reader :text
    attr_reader :type

    def initialize(answer, person, type=@@SIMPLE_ANSWER)
        @person = person.name  # Person who taught this answer.
        @text = text  # Text for this answer.
        @type = type  # Type of answer.
        @feedback = 1  # Amount of feedback received.
        @weight = getPerson().getInfluence()  # Answer weight.
    end

    def sendFeedback(person, connotation=0)
        # Send feedback related to an answer.
        @feedback *= 1.1
        if connotation >= 0 and connotation <= 1
            @weight *= 1.0 + (0.1 + connotation * person.getInfluence())
        elsif connotation <= 0 and connotation >= -1
            @weight /= 1.0 + (0.5 + connotation.abs * person.getInfluence())
        end
    end

    def getWeight()
        # Return answer weight.
        return @weight * getPerson().getInfluence() * @feedback / 100
    end

    def getPerson()
        # Get answer teacher.
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
