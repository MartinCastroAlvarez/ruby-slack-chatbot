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
    # :getMessage: Get one message by id.
    # :learn: Teach a new message.

    include Singleton

    def initialize()
        @db = {}
        @dbInverted = {}
    end

    def getMessage(mid) 
        return @db[mid]
    end

    def learn(message, answer)
        raise ArgumentError, "Invalid Message" unless message.instance_of? Message
        raise ArgumentError, "Invalid Answer" unless answer.instance_of? Answer
        if not @db.include? message.analyzer.message
            @db[message.analyzer.message] = message
            message.tokens.db.each do |tid, token|
                if not @dbInverted.key?(tid)
                    @dbInverted[tid] = {}
                end
                if not @dbInverted[tid].key? message.analyzer.message
                    @dbInverted[tid][message.analyzer.message] = 0
                end
                @dbInverted[tid][message.analyzer.message] += 1 + Math.sqrt(token.relevance) / 1000.0
            end
        end
        @db[message.analyzer.message].addAnswer(answer)
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
        message.tokens.db.each do |tid, token|
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
        _matches = []
        for i in (_scores.size-1) * 90 / 100 ... _scores.size
            _matches.push(_scores[i])
        end

        # Calculate the differenc between strings.
        for i in 0..._matches.size
            a = _matches[i][0]
            b = message.analyzer.message
            _matches[i][1] = diff(a, b)
        end

        # Retutrn response.
        return getMessage(_matches[-1][0]).getOneAnswer()
        
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
        @dbInverted.each do |tid, score|
            s.concat("#{tid}: #{score}\n")
        end
        s.concat("\n")
        return s
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
    m = Message.new("My sunshine!")
    w.learn(m, Answer.new("Yes, this is the sunshine!", p))
    w.learn(m, Answer.new("No! this is NOT the sunshine!", p))
    w.learn(m, Answer.new("Nice SUNSHINE dude!", p))
    w.learn(m, Answer.new("The North Remembers!", p))
    m = Message.new("My not so far away sunshine!")
    w.learn(m, Answer.new("Yeah, definitely right!", p))
    puts w.toString()
    puts w.getBestAnswer(Message.new("My sunshine far away")).message
end
