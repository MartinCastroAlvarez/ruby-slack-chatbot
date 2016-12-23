require_relative "tokenizer"
require_relative "analyzer"
require_relative "answer"
require_relative "person"
require_relative "people"


class Message

    # Attributes
    # ------------------
    # :literal: Literal message without being analyzed.
    # :analyzer: Message after being analyzed.
    # :tokens: Reference to Tokenizer object.
    # :answers: Answers to this message.
    #
    # Methods
    # ------------------
    # :sendFeedback: Encourage or discourage an answer.
    # :toString: Convert Message to string.
    # :teach: Add a new answer to this message.
    # :getBestAnswer: Gest best answer for this message.

    attr_reader :literal
    attr_reader :analyzer
    attr_reader :tokens
    attr_reader :answers

    def initialize(message)
        @literal = message
        @answers = {}
        @analyzer = Analyzer.new(message)
        @db = Tokenizer.new(@analyzer.message)
    end

    def teach(answer)
        raise ArgumentError, "Invalid Answer" unless answer.instance_of? Answer
        if not @answers.include? answer.message
            @answers[answer.message] = answer
        end
    end

    def sendFeedback(person, answer, connotation=0)
        raise ArgumentError, "Invalid Person" unless person.instance_of? Person
        raise ArgumentError, "Invalid Answer" unless answer.instance_of? Answer
        @answers[answer.message].sendFeedback(person, connotation)
    end

    def getBestAnswer(person) 
        _total = 0
        @answers.each do |aid, answer|
            _total += answer.getWeight()
        end
        _rand = rand(0..._total)
        @answers.each do |aid, answer|
            if _rand < a.getWeight()
                sendFeedback(person, answer)
                return answer
            end
            _rand = _rand - a.getWeigth()
        end
        raise RuntimeError, "No answer"
    end

    def toString()
        s = ""
        s.concat("Message\n")
        s.concat("-----------------------------\n")
        s.concat("#{@literal}\n")
        s.concat("\n")
        s.concat("Answers\n")
        s.concat("-----------------------------\n")
        @answers.each do |aid, answer|
            s.concat(answer.toString())
        end
        s.concat("\n")
        s.concat(@db.toString())
        s.concat(@analyzer.toString())
        return s
    end

end

if __FILE__ == $0
    m = Message.new("Hi! This is Martin! Nice to meet you. How are you?")
    p = People.instance.get("martin")
    a = Answer.new("Hi, this is my answer!!", p)
    m.teach(a)
    m.teach(Answer.new("Hi there!!", p))
    m.teach(Answer.new("Answer #3", p))
    m.sendFeedback(p, a, 0.5)
    puts m.toString()
end
