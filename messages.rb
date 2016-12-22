require_relative "analyzers"


# https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Ruby
def levenshtein(first:, second:)
    matrix = [(0..first.length).to_a]
    (1..second.length).each do |j|
        matrix << [j] + [0] * (first.length)
    end
    (1..second.length).each do |i|
        (1..first.length).each do |j|
            if first[j-1] == second[i-1]
                matrix[i][j] = matrix[i-1][j-1]
            else
                matrix[i][j] = [
                    matrix[i-1][j],
                    matrix[i][j-1],
                    matrix[i-1][j-1],
                ].min + 1
            end
        end
     end
     return matrix.last.last
end


class Message

    @@db = {}
    @@dbInverted = {}

    attr_reader :id
    attr_reader :answers

    # Classmethod
    def self.getBestAnswer(analyzed_message)

        # Check inverted index.
        _scores = {}
        analyzed_message.tokens.tokens.each do |tid, token|
            if @@dbInverted.key?(tid)
                @@dbInverted[tid].each do |mid, relevance|
                    if not _scores.key?(mid)
                        _scores[mid] = 0.0
                    end
                    _scores[mid] += relevance * analyzed_message.tokens.getRelevance(tid)
                end
            end
        end

        # Sort by scores/relevance
        _scores = _scores.sort_by {|_key, value| value}

        # Remove worst 90% answers.
        _bestAnswers = []
        for i in (_scores.size-1) * 90 / 100 ... _scores.size
            _bestAnswers.push(_scores[i])
        end

        # Calculate the differenc between strings.
        for i in 0..._bestAnswers.size
            a = _bestAnswers[i][0]
            b = analyzed_message.analyzed
            _bestAnswers[i][1] = levenshtein(first: a, second: b)
        end

        # Retutrn response.
        _response = {}
        _response['message'] = _bestAnswers[-1][0]
        _response['differenciation'] = _bestAnswers[-1][1]
        return _response
        
        
    end

    def initialize(analyzed_message)

        @id = analyzed_message.analyzed # Unique message ID.
        @answers = {}  # Get all possible answers.

        # Learn new message.
        if not @@db.key?(id)
            @@db[id] = self
        end

        # Generate inverted index.
        analyzed_message.tokens.tokens.each do |name, token|
            if not @@dbInverted.key?(name)
                @@dbInverted[name] = {}
            end
            if not @@dbInverted[name].key?(@id)
                @@dbInverted[name][@id] = 0
            end
            @@dbInverted[name][@id] += token['relevance']
        end

    end

    def teach(answer)
        @answers.push(answer)
    end

    def toString()
        # Print Message as string.
        return "#{@id} #{@answers}"
    end

end

if __FILE__ == $0
    Message.new(Analyzer.new("Are you Martin?"))
    Message.new(Analyzer.new("Is this where Martin lives?"))
    Message.new(Analyzer.new("I'm Martin"))
    Message.new(Analyzer.new("My name is Martin. How are you?"))
    Message.new(Analyzer.new("Hi! This is Martin! Nice to meet you!"))
    a = Analyzer.new("I am Martin")
    r = Message.getBestAnswer(a)
    puts r
end
