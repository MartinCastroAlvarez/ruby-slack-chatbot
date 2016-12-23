require_relative "message"
require_relative "wisdom"
require_relative "person"
require_relative "answer"
require_relative "people"


class Vallerie

    # Attributes
    # ------------------
    # :lastMessage: Last received message.
    # :lastAnswer: Last sent message.
    #
    # Methods
    # ------------------
    # :answer: Provider a chat answer for one message.

    @@version = 6

    attr_reader :lastMessage
    attr_reader :lastAnswer

    def initialize()
        @lastMessage = nil
        @lastAnswer = nil
    end

    def answer(personName, messageText)

        # Clean params.
        message = Message.new(messageText)
        person = People.instance.get(personName)

        # Update familiarity and affinity with this person.
        person.interact(message.analyzer.connotation)

        # Is it a learning suggestion?
        if @lastMessage and message.analyzer.isLearningSuggestion
            answer = Answer.new(message.analyzer.literal, person)
            Wisdom.instance.learn(@lastMessage, answer)
            return [
                "Thanks!!",
                "Thanks! I will consider it next time!",
                "Good to know!",
                "Great! Thank you!",
                "Wow! Thanks!",
                "Cool :)",
                "Oh, I see!",
            ].sample
        end

        # Send feedback about last answer.
        if @lastMessage and @lastAnswer
            Wisdom.instance.sendFeedback(person, @lastMessage, @lastAnswer, message.analyzer.connotation)
        end

        # Update Vallerie.
        @lastMessage = message
        @lastAnswer = nil

        # Get best possible answer.
        begin
            answer = Wisdom.instance.getBestAnswer(message)
        rescue StandardError
            return [
                "Oohps! I really don't know!!",
                "I don't know!",
                "What do you suggest?",
                "What would that be?",
                "Need some help with that!",
                "Sorry, I am not sure...",
                "Please help me answer that!",
            ].sample
        end

        # Update Vallerie.
        @lastAnswer = answer

        return answer.message

    end

end

if __FILE__ == $0
    def say(v, person, message)
        printf "%-15s %s\n", person, message 
        r = v.answer(person, message)
        printf "%-15s %s\n", "Vallerie", r
    end
    v = Vallerie.new()
    say(v, "martin", "Hello, how are you?")
    say(v, "martin", "You may say: Fine, and you?")
    say(v, "martin", "Hello, how are you?")
end
