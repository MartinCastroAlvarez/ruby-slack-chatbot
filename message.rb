require_relative "tokenizer"
require_relative "analyzer"


class Message

    # Attributes
    # ------------------
    # :literal: Literal message without being analyzed.
    # :analyzer: Message after being analyzed.
    # :tokens: Reference to Tokenizer object.
    #
    # Methods
    # ------------------
    # :toString: Convert Message to string.

    attr_reader :literal
    attr_reader :analyzer
    attr_reader :tokens

    def initialize(message)
        @literal = message
        @analyzer = Analyzer.new(message)
        @tokens = Tokenizer.new(@analyzer.message)
    end

    def toString()
        return @literal
    end

end

if __FILE__ == $0
    m1 = Message.new("Hi! This is Martin! Nice to meet you. How are you?")
    puts m1.toString()
end
