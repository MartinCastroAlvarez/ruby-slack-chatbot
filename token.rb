

class Token

    # Attributes
    # ------------------
    # :name: Name of the token.
    # :relevance: Score for this token.
    # :found: Amount of matches in a sentence.
    #
    # Methods 
    # ------------------
    # :toString: Convert Token to string.

    attr_reader :name
    attr_reader :found
    attr_writer :found
    attr_reader :relevance
    attr_writer :relevance

    def initialize(name, found=0, relevance=0)
        @name = name
        @found = found
        @relevance = relevance
    end

    def toString()
        return "#{@name} [found=#{@found}] [relevance=#{@relevance}]\n"
    end

end

if __FILE__ == $0
    t = Token.new("going", 1, 30)
    puts t.toString()
end
