require_relative "message"
require_relative "person"
require_relative "answer"
require_relative "people"
require "singleton"


class Wisdom

    # Attributes
    # ------------------
    # :db: Database for all messages.
    # :dbInverted: Inverted index database for @@db
    #
    # Methods
    # ------------------
    # :diff: Get numeric difference between two strings.
    # :toString: Convert Knowledge to string.
    # :getBestAnswer: Get best answer based for one message.
    # :sendFeedback: Send feedback to an answer.
    # :teach: Teach a new message.
    # :lastMessage: Stores last received message.
    # :lastResponse: Stores last sent response.

    include Singleton

    def initialize()
        @db = {}
        @dbInverted = {}
    end

    def teach(message, answer=nil)

        raise ArgumentError, "Invalid Message" unless message.instance_of? Message
        raise ArgumentError, "Invalid Answer" unless answer.instance_of? Answer

        # Learn new message.
        if not @db.include? message.analyzer.message
            @db[message.analyzer.message] = message
        end

        # Learn new answer.
        if not @db[message.analyzer.message].include? answer.message
            @db[message.analyzer.message][answer.message] = answer
        end

        # Generate inverted index.
        message.tokens.getAll().each do |tid, token|
            if not @dbInverted.key?(tid)
                @dbInverted[tid] = {}
            end
            if not @dbInverted[tid].key? message.analyzer.message
                @dbInverted[tid][message.analyzer.message] = 0
            end
            @dbInverted[tid][message.analyzer.message] += token['relevance']
        end

    end

    def sendFeedback(person, message, answer, connotation=0)
        raise ArgumentError, "Invalid Person" unless person.instance_of? Person
        raise ArgumentError, "Invalid Answer" unless answer.instance_of? Answer
        raise ArgumentError, "Invalid Message" unless message.instance_of? Message
        @db[message.analyzer.message].sendFeedback(person, answer, connotation)
    end

    def getBestAnswer(message)
        raise ArgumentError, "Invalid Message" unless message.instance_of? Message

        # Check inverted index.
        _scores = {}
        message.tokens.getAll().each do |tid, token|
            if @dbInverted.key?(tid)
                @dbInverted[tid].each do |mid, relevance|
                    if not _scores.key?(mid)
                        _scores[mid] = 0.0
                    end
                    _scores[mid] += relevance * message.tokens.getRelevance(tid)
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
            b = message.analyzed
            _bestAnswers[i][1] = levenshtein(a, b)
        end

        # Retutrn response.
        _response = {}
        _response['message'] = _bestAnswers[-1][0]
        _response['differenciation'] = _bestAnswers[-1][1]

        return _response
        
        
    end

    def toString()
        s = ""
        s.concat("===========================================\n")
        s.concat("Messages\n")
        s.concat("===========================================\n")
        @db.each do |mid, message|
            s.concat(message.toString())
        end
        s.concat("===========================================\n")
        s.concat("Inverted Index\n")
        s.concat("===========================================\n")
        @db.each do |token, score|
            s.concat("#{token} => #{score}")
        end
        s.concat("\n")
        return s
    end

    def toString()
        # Print Message as string.
        return @db
    end

    def diff(first, second)
        # Levenshtein algorithm
        # https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Ruby
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

end

if __FILE__ == $0
    w = Wisdom.instance
    p = People.instance.get("martin")
    m = Message.new("This is the sunshine!")
    w.teach(p, m, Answer.new("Yes, this is the sunshine!", p))
    w.teach(p, m, Answer.new("No! this is NOT the sunshine!", p))
    w.teach(m)
end
