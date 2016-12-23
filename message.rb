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
    # :toString: Convert Message to string.
    # :getAnswer: Get answer by id.
    # :addAnswer: Add a new answer if not exists.
    # :getBestAnswer: Gest best answer for this message.

    attr_reader :literal
    attr_reader :analyzer
    attr_reader :tokens

    def initialize(message)
        @literal = message
        @answers = {}
        @analyzer = Analyzer.new(message)
        @tokens = Tokenizer.new(@analyzer.message)
    end

    def addAnswer(answer) 
        raise ArgumentError, "Invalid Answer" unless answer.instance_of? Answer
        if not @answers.include? answer.message
            @answers[answer.message] = answer
        end
    end

    def getAnswer(id) 
        return @answers[id]
    end

    def getBestAnswer() 
        _total = 0
        @answers.each do |aid, answer|
            _total += answer.getWeight()
        end
        _rand = rand(0..._total)
        @answers.each do |aid, answer|
            if _rand < answer.getWeight()
                return answer
            end
            _rand = _rand - answer.getWeight()
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
        s.concat(@tokens.toString())
        s.concat(@analyzer.toString())
        return s
    end

end

if __FILE__ == $0
    m = Message.new("Hi! This is Martin! Nice to meet you. How are you?")
    p = People.instance.get("martin")
    m.addAnswer(Answer.new("Hi, this is my answer!!", p))
    m.addAnswer(Answer.new("Hi there!!", p))
    m.addAnswer(Answer.new("Hello!!", p))
    puts m.toString()
    puts m.getBestAnswer().message
end
