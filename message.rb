require_relative "tokenizer"
require_relative "analyzer"
require_relative "answer"
require_relative "person"


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
    # :learn: Add a new answer to this message.
    # :getBestAnswer: Gest best answer for this message.

    attr_reader :literal
    attr_reader :analyzer
    attr_reader :tokens
    attr_reader :answers

    def initialize(message)
        @literal = message
        @answers = {}
        @analyzer = Analyzer.new(message)
        @tokens = Tokenizer.new(@analyzer.message)
    end

    def learn(answer)
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
        @answers.each do |answer, a|
            _total += a.getWeight()
        end
        _rand = rand(0..._total)
        @answers.each do |answer, a|
            if _rand < a.getWeight()
                return a
            end
            _rand = _rand - a.getWeigth()
        end
        raise RuntimeError, "No answer"
    end

    def toString()
        s = ""
        s.concat("-----------------------------\n")
        s.concat("Message\n")
        s.concat("-----------------------------\n")
        s.concat("Literal: #{@literal}\n")
        @tokens.each do |name, token|
            s.concat("#{name} found=#{token['found']} relevance=#{token['relevance']}\n")
        end
        s.concat("-----------------------------\n")
        s.concat(@tokens.toString())
        s.concat(@analyzer.toString())
        return s
    end

end

if __FILE__ == $0
    m = Message.new("Hi! This is Martin! Nice to meet you. How are you?")
    puts m.toString()
    p = Person.new("martin")
    a = Answer.new("Hi, this is my answer!!", p)
    m.learn(a)
    m.sendFeedback(p, a, 0.5)
end
