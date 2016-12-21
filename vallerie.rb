

class Vallerie

    @@version = 2
    @@SIMPLE_ANSWER = 'simple_answer'
    @@LEARNING = [
        "Maybe you can say: ",
        "maybe you can say: ",
        "You may say: ",
        "you may say: ",
        "You may also say: ",
        "you may also say: ",
        "You can say: ",
        "you can say: ",
        "You can also say: ",
        "you can also say: ",
    ]
    @@POSITIVE = [
        "like",
        "love",
        "cool",
    ]
    @@NEGATIVE = [
        "sucks",
        "bad",
        "hate",
        "disgust",
        "terrible",
    ]

    def initialize()
        @lastMessage = nil
        @lastAnswer = nil
        @answers = {}
        @people = {}
    end

    # ---------------------------------------------------------
    # Social Influence.
    # ---------------------------------------------------------

    def getPerson(person)
        # Get (or create) one person from database.
        if not @people.key?(person)
            @people[person] = {}
            @people[person]["familiarity"] = 1
            @people[person]["affinity"] = 1
        end
        return @people[person]
    end

    def getFamiliarity(person)
        # Increase familiarity with one person.
        return self.getPerson(person)["familiarity"]
    end

    def getAffinity(person)
        # Increase affinity with one person.
        return self.getPerson(person)["affinity"]
    end

    def increaseFamiliarity(person)
        # Increase familiarity with one person.
        self.getPerson(person)["familiarity"] *= 1.1
    end

    def increaseAffinity(person)
        # Increase affinity with one person.
        self.getPerson(person)["affinity"] *= 1.1
    end

    def decreaseAffinity(person)
        # Decrease affinity with one person.
        self.getPerson(person)["affinity"] /= 1.5
    end

    def getAverageFamiliarity()
        # Get average familiarity for all people.
        total = 0
        count = 0
        @people.each do |name, person|
            total += person['familiarity']
            count += 1
        end
        if count > 0
            return total / count
        else
            return 0
        end
    end

    def getAverageAffinity()
        # Get average affinity for all people.
        total = 0
        count = 0
        @people.each do |name, person|
            total += person['affinity']
            count += 1
        end
        if count > 0
            return total / count
        else
            return 0
        end
    end

    def getInfluence(person)
        # Get influence from a person.
        return (self.getFamiliarity(person) * self.getAffinity(person)) / (self.getAverageAffinity() * self.getAverageFamiliarity())
    end

    # ---------------------------------------------------------
    # Machine Learning Messages.
    # ---------------------------------------------------------

    def getMessage(message)
        # Return reference to one message.
        if not @answers.key?(message)
            @answers[message] = {}
            @answers[message]["answers"] = {}
        end
        return @answers[message]
    end

    def getAnswer(message, answer)
        # Return reference to one answer.
        return self.getMessage(message)['answers'][answer]
    end

    def sendPositiveFeedback(message, answer, person)
        # Send positive feedback about last answer.
        self.getAnswer(message, answer)['social_acceptance'] += self.getInfluence(person)
    end

    def sendNegativeFeedback(message, answer, person)
        # Send negative feedback about last answer.
        self.getAnswer(message, answer)['social_acceptance'] -= self.getInfluence(person)
	if self.getAnswer(message, answer)['social_acceptance'] <= 0
            self.getAnswer(message, answer)['social_acceptance'] = 0
        end
    end

    def teach(message, answer, person)
        # Teach Vallerie to deliver a new simple answer.
        if not self.getMessage(message).key?(answer)
            self.getMessage(message)['answers'][answer] = {}
            self.getMessage(message)['answers'][answer]['social_acceptance'] = self.getInfluence(person)
            self.getMessage(message)['answers'][answer]['type'] = @@SIMPLE_ANSWER
            self.getMessage(message)['answers'][answer]['creator'] = person
            self.getMessage(message)['answers'][answer]['message'] = answer
        end
        self.sendPositiveFeedback(message, answer, person)
    end

    def getBestAnswer(message, person) 
        # Provide an answer for that question with a % of reliability.
        response = {}
        _total = 0
        response['isIA'] = false
        response['reliability'] = 100
        response['social_acceptance'] = 0
        response['message'] = [
            "Mmm... what do you think I should say?",
            "I don't know! Do you have any suggestions?",
            "What would you say?",
        ].sample
        self.getMessage(message)['answers'].each do |answer, a|
            if a['social_acceptance'] > 0
                # TODO: Multiple social_acceptance x n if Vallerie likes this person.
                _total = _total + a['social_acceptance']
            end
        end
        _rand = rand(0..._total)
        self.getMessage(message)['answers'].each do |answer, a|
            if a['social_acceptance'] >= 0
                if _rand < a['social_acceptance']
                    response['message'] = a['message']
                    # TODO: Multiple social_acceptance x n if Vallerie likes this person.
                    response['social_acceptance'] = a['social_acceptance']
                    response['isIA'] = true
                    break
                end
                _rand = _rand - a['social_acceptance']
            end
        end
        if response['isIA']
            if _total > 0
                response['reliability'] = 100 * response['social_acceptance'] / _total
            else
                response['reliability'] = 0
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

    def analyze(message)
        # Removes all noise from message.
        # TODO: Learn negative messages.
        for i in 0...@@LEARNING.size
            message = message.sub(@@LEARNING[i], "")
        end
        return message
    end

    def isPositive(message)
        # Return true if message is positive.
        # TODO: Learn positive messages.
        # TODO: Implement some Natural Language parser.
        for i in 0...@@POSITIVE.size
            if message.include? @@POSITIVE[i]
                return true
            end
        end
        return false
    end

    def isNegative(message)
        # Return true if message is positive.
        # TODO: Learn negative messages.
        # TODO: Implement some Natural Language parser.
        for i in 0...@@NEGATIVE.size
            if message.include? @@NEGATIVE[i]
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
        cleaned = self.analyze(message)

        # Become more familiar with that person.
        self.increaseFamiliarity(person)

        # Evaluate if message is positive or negative.
        _isPositive = false
        _isNegative = false
        if self.isPositive(cleaned)
            _isPositive = true
        elsif self.isNegative(cleaned)
            _isNegative = true
        end

        # Teach Vallerie a new answer?
        if self.isLearningSuggestion(message)
            
            # Action is: Learning.
            if self.getLastMessage()
                self.teach(self.getLastMessage(), cleaned, person)
                self.increaseAffinity(person)
                return [
                    "I will consider that next time!",
                    "Gotcha!",
                    "Thanks!!",
                ].sample
            else
                self.decreaseAffinity(person)
                return [
                    "I really don't know what you are talking about!",
                    "You haven't asked anything yet!",
                ].sample
            end

        elsif _isPositive or _isNegative

            # Action is Feedback.
            if self.getLastMessage() and self.getLastAnswer()
                # Send positive or negative feedback about last answer or question.
                if _isPositive
                    self.sendPositiveFeedback(self.getLastMessage(), self.getLastAnswer(), person)
                    self.increaseAffinity(person)
                    return [
                        "Thanks you! I like it!",
                        "Sounds good!",
                    ].sample
                else _isNegative
                    self.sendNegativeFeedback(self.getLastMessage(), self.getLastAnswer(), person)
                    self.decreaseAffinity(person)
                    return [
                        "I will take care of what I say next time...",
                        "Sorry, I didn't know it was so rude...",
                    ].sample
                end
            else
                # Like or dislike a bit more that person.
                if _isPositive
                    self.increaseAffinity(person)
                    return [
                        "Thank you!!!",
                        "You are really nice!",
                        ":)",
                    ].sample
                else _isNegative
                    self.decreaseAffinity(person)
                    return [
                        "Not nice!",
                        "Uhm!",
                        "...",
                    ].sample
                end
            end

        end
        # End of Learning or Feedback actions.

        # Reset last message and answer.
        self.setLastMessage(cleaned)
        self.setLastAnswer(nil)

        # Provide an answer for that question.
        response = self.getBestAnswer(cleaned, person)
        if response['isIA']
            self.setLastAnswer(response["message"])
            if response['reliability'] < 30
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
say(v, "martin", "Maybe you can say: I prefer Blue!")
say(v, "martin", "What is your favorite color?")
say(v, "alejandro", "I hate it!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "alejandro", "What is your favorite color?")
say(v, "castro", "You can also say: My favorite color is Red!")
say(v, "martin", "What is your favorite color?")
