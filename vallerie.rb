

class Vallerie

    @@version = 3
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

    # A list of positive words that Vallerie uses to 
    # determine whether a message is positive or negative.
    @@POSITIVE = [
        "like", "love", "cool", "peace", "enjoy", "joy", "trust", "witty",
        "awesome", "legit", "great", "liked", "loved", "nice", "good",
        "masterfully", "magnificent", "thrilling", "enaged", "engaged",
        "engaging", "super", "superb", "engages", "neat", "best", "spectacle",
        "spectacular", "smart", "charming", "success", "successful", "want",
        "fantastic", "divine", "beautiful", "pretty", "attractive", "goodlooking",
        "brilliant", "immersive", "smooth", "admire", "admired", "admires",
        "breathtaking", "funny", "funnier", "funniest", "thoughtful", "hilarious",
    ]

    # A list of negative words that Vallerie uses to 
    # determine whether a message is positive or negative.
    @@NEGATIVE = [
        "sucks", "terrible", "awful", "bored", "bore", "boring", "lame", "bitch",
        "bad", "suck", "crap", "hideous", "shameful", "ashamed", "wasted",
        "don't", "merely", "forgettable", "garbage", "trash", "hated", "dumb",
        "doesn't", "dumbest", "plotholes", "meh", "fuck", "faggot", "asshole",
        "not", "won't", "hate", "disgust", "terrible", "stupid", "idiot",
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
            @people[person]["familiarity"] = 1.0
            @people[person]["affinity"] = 1.0
        end
        return @people[person]
    end

    def getFamiliarity(person)
        # Get familiarity with a person.
        return self.getPerson(person)["familiarity"]
    end

    def getAffinity(person)
        # Get affinity with a person.
        return self.getPerson(person)["affinity"]
    end

    def increaseFamiliarity(person)
        # Increase familiarity with one person.
        self.getPerson(person)["familiarity"] *= 1.1
    end

    def increaseAffinity(person, positivity=1)
        # Increase affinity with one person.
        self.getPerson(person)["affinity"] *= 1.0 + (0.1 + positivity.abs)
    end

    def decreaseAffinity(person, negativity)
        # Decrease affinity with one person.
        self.getPerson(person)["affinity"] /= 1.0 + (0.5 + negativity.abs)
    end

    def getAverageFamiliarity()
        # Get average familiarity for all people.
        total = 0.0
        count = 0.0
        @people.each do |name, person|
            total += person['familiarity']
            count += 1.0
        end
        if count > 0
            return total / count
        else
            return 0
        end
    end

    def getAverageAffinity()
        # Get average affinity for all people.
        total = 0.0
        count = 0.0
        @people.each do |name, person|
            total += person['affinity']
            count += 1.0
        end
        if count > 0
            return total / count
        else
            return 0.0
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
            self.getAnswer(message, answer)['social_acceptance'] = 0.0
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
        _total = 0.0
        response['isIA'] = false
        response['reliability'] = 100.0
        response['social_acceptance'] = 0.0
        response['message'] = [
            "Mmm... what do you think I should say?",
            "I don't know! Do you have any suggestions?",
            "What would you say?",
        ].sample
        self.getMessage(message)['answers'].each do |answer, a|
            if a['social_acceptance'] > 0
                # TODO: Multiple social_acceptance x n if Vallerie likes this person.
                _total = _total + a['social_acceptance'] + self.getInfluence(a['creator']) / 100.0
            end
        end
        _rand = rand(0..._total)
        self.getMessage(message)['answers'].each do |answer, a|
            if a['social_acceptance'] >= 0
                if _rand < (a['social_acceptance'] + self.getInfluence(a['creator']) / 100.0)
                    response['message'] = a['message']
                    response['social_acceptance'] = a['social_acceptance']
                    response['isIA'] = true
                    break
                end
                _rand = _rand - a['social_acceptance'] - self.getInfluence(a['creator']) / 100.0
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

    def analyze(message)
        # Removes all noise from message.
        # TODO: Learn negative messages.
        for i in 0...@@LEARNING.size
            message = message.sub(@@LEARNING[i], "")
        end
        return message
    end

    def isPositiveOrNegative(message)
        # Return true if message is positive.
        # TODO: Learn positive messages.
        # TODO: Implement some Natural Language parser.
        _len = message.split.size
        _found = 0.0
        _message = message.downcase  
        for i in 0...@@POSITIVE.size
            if _message.include? @@POSITIVE[i]
                _found += 1.0
            end
        end
        for i in 0...@@NEGATIVE.size
            if _message.include? @@NEGATIVE[i]
                _found -= 3.0
            end
        end
        if _len > 0
            return _found / _len
        else
            return 0
        end
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
        _isPositiveOrNegative = self.isPositiveOrNegative(cleaned)
        _minRelevance = 0.2
        if _isPositiveOrNegative > _minRelevance
            self.increaseAffinity(person, _isPositiveOrNegative)
        elsif _isPositiveOrNegative > 0.2
            self.decreaseAffinity(person, _isPositiveOrNegative)
        end

        # Teach Vallerie a new answer?
        if self.getLastMessage() and self.isLearningSuggestion(message)
            self.teach(self.getLastMessage(), cleaned, person)
            self.increaseAffinity(person)
            return [
                "I will consider that next time!",
                "Gotcha!",
                "I like it!",
                "I appreciate that!",
                "Thanks!!",
            ].sample
        end

        # Send Feedback about last answer..
        if self.getLastMessage() and self.getLastAnswer()
            # Send positive or negative feedback about last answer or question.
            if _isPositiveOrNegative > _minRelevance
                self.sendPositiveFeedback(self.getLastMessage(), self.getLastAnswer(), person)
            elsif _isPositiveOrNegative < -1 * _minRelevance
                self.sendNegativeFeedback(self.getLastMessage(), self.getLastAnswer(), person)
            end
        end

        # Reset last message and answer.
        self.setLastMessage(cleaned)
        self.setLastAnswer(nil)

        # Provide an answer for that question.
        response = self.getBestAnswer(cleaned, person)
        if response['isIA']
            self.setLastAnswer(response["message"])
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
say(v, "alejandro", "You stupid!")
say(v, "alejandro", "What is your favorite color?")
say(v, "castro", "You can also say: My favorite color is Red!")
say(v, "castro", "You can also say: Green is the best!")
say(v, "martin", "What is your favorite color?")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "I like it!")
say(v, "martin", "You can also say: What about yellow?")
say(v, "martin", "What is your favorite color?")
