require_relative "messages"
require_relative "people"


class Vallerie

    @@version = 4

    attr_reader :lastMessage
    attr_reader :lastAnswer

    def initialize()
        @lastMessage = nil
        @lastAnswer = nil
        @answers = {}
        @answersInverted = {}
        @people = {}
    end

    # ---------------------------------------------------------
    # Machine Learning Messages.
    # ---------------------------------------------------------

    def getMessage(message)
        # Return reference to one message.
        if not @answers.key?(message['analyzed'])
            @answers[message['analyzed']] = {}
            @answers[message['analyzed']]["answers"] = {}
        end
        return @answers[message]
    end

    def getAnswer(message, answer)
        # Return reference to one answer.
        return getMessage(message)['answers'][answer]
    end

    def sendPositiveFeedback(message, answer, person)
        # Send positive feedback about last answer.
        getAnswer(message, answer)['social_acceptance'] += getInfluence(person)
    end

    def sendNegativeFeedback(message, answer, person)
        # Send negative feedback about last answer.
        getAnswer(message, answer)['social_acceptance'] -= getInfluence(person)
	if getAnswer(message, answer)['social_acceptance'] <= 0
            getAnswer(message, answer)['social_acceptance'] = 0.0
        end
    end

    def teach(message, answer, person)
        # Teach Vallerie to deliver a new simple answer.
        if not getMessage(message).key?(answer)
            getMessage(message)['answers'][answer] = {}
            getMessage(message)['answers'][answer]['social_acceptance'] = getInfluence(person)
            getMessage(message)['answers'][answer]['type'] = @@SIMPLE_ANSWER
            getMessage(message)['answers'][answer]['creator'] = person
            getMessage(message)['answers'][answer]['message'] = answer
        end
        sendPositiveFeedback(message, answer, person)
    end

    def getBestAnswer(message, person) 
        # Provide an answer for that question with a % of reliability.
        response = {}
        _total = 0.0
        response['isIA'] = false
        response['reliability'] = 100.0
        response['social_acceptance'] = 0.0
        response['message'] = [
            "Mmm... what do you think I should say?",
            "I don't know! Do you have any suggestions?",
            "What would you say?",
        ].sample
        getMessage(message)['answers'].each do |answer, a|
            if a['social_acceptance'] > 0
                # TODO: Multiple social_acceptance x n if Vallerie likes this person.
                _total = _total + a['social_acceptance'] + getInfluence(a['creator']) / 100.0
            end
        end
        _rand = rand(0..._total)
        getMessage(message)['answers'].each do |answer, a|
            if a['social_acceptance'] >= 0
                if _rand < (a['social_acceptance'] + getInfluence(a['creator']) / 100.0)
                    response['message'] = a['message']
                    response['social_acceptance'] = a['social_acceptance']
                    response['isIA'] = true
                    break
                end
                _rand = _rand - a['social_acceptance'] - getInfluence(a['creator']) / 100.0
            end
        end
        if response['isIA']
            if _total > 0
                response['reliability'] = response['social_acceptance'] / _total
            else
                response['reliability'] = 0.0
            end
        end
        return response
    end

    # ---------------------------------------------------------
    # Natural Language Analysis.
    # ---------------------------------------------------------

    def isLearningSuggestion(message)
        # Return true if message is an advice to answer a message.
        # TODO: Learn learning suggestions.
        for i in 0...@@LEARNING.size
            if message.include? @@LEARNING[i]
                return true
            end
        end
        return false
    end


    def tokenizer(message)
        return message
    end

    # ---------------------------------------------------------
    # Answer a question using AI.
    # ---------------------------------------------------------

    def getLastAnswer()
        # Return last answer that was sent.
        return @lastAnswer
    end

    def getLastMessage()
        # Return last question that was answered.
        return @lastMessage
    end

    def setLastMessage(message)
        # Update last message.
        @lastMessage = message
    end

    def setLastAnswer(answer)
        # Update last question.
        @lastAnswer = answer
    end

    def answer(person, message)

        # Clean message.
        message = analyze(message)

        # Become more familiar with that person.
        increaseFamiliarity(person)

        # Evaluate if message is positive or negative.
        _isPositiveOrNegative = isPositiveOrNegative(message)
        _minRelevance = 0.2
        if _isPositiveOrNegative > _minRelevance
            increaseAffinity(person, _isPositiveOrNegative)
        elsif _isPositiveOrNegative > 0.2
            decreaseAffinity(person, _isPositiveOrNegative)
        end

        # Teach Vallerie a new answer?
        if getLastMessage() and isLearningSuggestion(message)
            teach(getLastMessage(), message, person)
            increaseAffinity(person)
            return [
                "I will consider that next time!",
                "Gotcha!",
                "I like it!",
                "I appreciate that!",
                "Thanks!!",
            ].sample
        end

        # Send Feedback about last answer..
        if getLastMessage() and getLastAnswer()
            # Send positive or negative feedback about last answer or question.
            if _isPositiveOrNegative > _minRelevance
                sendPositiveFeedback(getLastMessage(), getLastAnswer(), person)
            elsif _isPositiveOrNegative < -1 * _minRelevance
                sendNegativeFeedback(getLastMessage(), getLastAnswer(), person)
            end
        end

        # Reset last message and answer.
        setLastMessage(message)
        setLastAnswer(nil)

        # Provide an answer for that question.
        response = getBestAnswer(message, person)
        if response['isIA']
            setLastAnswer(response["message"])
            if response['reliability'] < 0.3
                doubt = [
                    "I am not completely sure, but",
                    "Not sure, but",
                    "It may sound strange, but",
                ].sample
                return "#{doubt}... #{response['message']}"
            end
        end
        return response['message']

    end

end

def say(v, person, message)
    puts "#{person} - #{message}"
    r = v.answer(person, message)
    puts "Vallerie - #{r}"
end
v = Vallerie.new()
say(v, "martin", "What is your favorite color?")
say(v, "martin", "Maybe you can say: I like Blue!")
say(v, "martin", "What is your favorite color?")
say(v, "alejandro", "I hate it!")
say(v, "martin", "Maybe you can say: I hate you!")
say(v, "alejandro", "You stupid!")
say(v, "martin", "Maybe you can say: You talking to me?")
say(v, "alejandro", "What is your favorite color?")
say(v, "castro", "You can also say: My favorite color is Red!")
say(v, "castro", "You can also say: Green is the best!")
say(v, "martin", "What is your favorite color?")
say(v, "martin", "I like it!")
say(v, "martin", "Maybe you can say: Thanks!")
say(v, "martin", "I like it!")
say(v, "martin", "Maybe you can say: Nice!")
say(v, "martin", "Maybe you can say: Cool!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "What is your favorite color?")
say(v, "martin", "You can also say: What about yellow?")
say(v, "martin", "What is your favorite color?")
