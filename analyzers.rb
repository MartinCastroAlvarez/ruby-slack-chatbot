require_relative "tokenizers"


class Analyzer

     # Symbols that are removed from the string.
     @@SYMBOLS = [
        "_", "-", "\\?", "\!", "\\.", ":", ";", '"', "@", "\\$", 
        "#", "%", "\\^", "&", "\\(", "\\)", "\\[", "\\]", "\\{", "\\}", "<", 
        ">", "/", "\\\\", "|", "~", "`", "\\+", "=", "\\*", "¡", "«", 
        "«", "¿",
    ]

    # A list of positive words that Vallerie uses to 
    # determine whether a message is positive or negative.
    @@POSITIVE = [
        "like", "love", "cool", "peace", "enjoy", "joy", "trust", "witty", "heaven",
        "awesome", "legit", "great", "liked", "loved", "nice", "good", "welcome",
        "masterfully", "magnificent", "thrilling", "enaged", "engaged", "lovely",
        "engaging", "super", "superb", "engages", "neat", "best", "spectacle",
        "spectacular", "smart", "charming", "success", "successful", "want", "adorable",
        "fantastic", "divine", "beautiful", "pretty", "attractive", "goodlooking",
        "brilliant", "immersive", "smooth", "admire", "admired", "admires",
        "breathtaking", "funny", "funnier", "funniest", "thoughtful", "hilarious",
    ]

    # A list of negative words that Vallerie uses to 
    # determine whether a message is positive or negative.
    @@NEGATIVE = [
        "sucks", "terrible", "awful", "bored", "bore", "boring", "lame", "bitch",
        "bad", "suck", "crap", "hideous", "shameful", "ashamed", "wasted", "hell",
        "don't", "merely", "forgettable", "garbage", "trash", "hated", "dumb",
        "doesn't", "dumbest", "plotholes", "meh", "fuck", "faggot", "asshole",
        "not", "won't", "hate", "disgust", "terrible", "stupid", "idiot", "devil",
    ]

    @@LEARNING = [
        "maybe you can say",
        "you may say",
        "you may also say",
        "you can say",
        "you can also say",
    ]

    attr_reader :literal
    attr_reader :connotation
    attr_reader :analyzed
    attr_reader :isQuestion
    attr_reader :isLearningSuggestion
    attr_reader :tokens

    def initialize(message)
        @literal = message  # Store original message.
        @connotation = 0.0  # -1 if message is negative or 1 if message is positive.
        @analyzed = message.downcase  # Message after being analyzed.
        @isQuestion = false  # true if message is a question.
        @isLearningSuggestion = false  # true if message is a learning suggestion.
        @stopWords = 0.0  # Amount of stopwords.
        @tokens = nil  # Tokenized message.

        # Remove learning suggestions.
        for i in 0...@@LEARNING.size
            if @analyzed =~ /^#{@@LEARNING[i]}: / 
                @analyzed = @analyzed.sub(@@LEARNING[i], "")
                @isLearningSuggestion = true
            end
        end

        # Remove duplicated spaces.
        @analyzed = @analyzed.gsub("  ", " ")
        @analyzed = @analyzed.gsub("  ", " ")
        @analyzed = @analyzed.gsub("  ", " ")

        # Check if message is a question.
        if @analyzed =~ /\?$/ 
            @isQuestion = true
        end

        # Remove symbols.
        for i in 0...@@SYMBOLS.size
            @analyzed = @analyzed.gsub(/#{@@SYMBOLS[i]}/, "")
        end

        # Tokenize message.
        @tokens = Tokenizer.new(@analyzed)

        # Determine if message is possitive or negative.
        _found = 0.0
        _len = @literal.split.size
        for i in 0...@@POSITIVE.size
            if @analyzed.include? @@POSITIVE[i]
                _found += 1.0
            end
        end
        for i in 0...@@NEGATIVE.size
            if @analyzed.include? @@NEGATIVE[i]
                _found -= 3.0
            end
        end
        if _len > 0
            @connotation = _found / _len
        end

    end

    def toString()
        # Print Message as string.
        return "'#{@literal}' => '#{@analyzed}' [#{@connotation}] [Is Question? #{@isQuestion}] [Is Learning? #{@isLearningSuggestion}]"
    end

end

if __FILE__ == $0
    m1 = Analyzer.new("Hi! This is Martin! Nice to meet you. How are you?")
    puts m1.toString()
end
