module Tandem
  class Message


    MESSAGES_KEY = "tandem.messages" # Key used to access message strings in locale file

    # TODO: unit tests
    # Returns an array of strings (even if it's just an array of one string)
    def self.message_strings template_name, extras = nil
      # Will sample randomly if there are multiple strings for that template
      ret = Array(I18n.t("#{MESSAGES_KEY}.#{template_name}", extras)).sample
      return ret.split("\n") # split the result by \n if it is a multi-sms message
    end


    # Assumes only one string will be returned
    def self.message_string template_name, extras = nil
      self.message_strings(template_name, extras).first
    end

    # TODO: unit tests
    def self.activity_tenses act
      activity_tenses = I18n.t("tandem.activities.#{act}")
      Hash[activity_tenses.map{|k,v| ["activity_#{k}".to_sym, v]}]
    end

    def self.gender_pronouns gender
      pronouns = I18n.t("tandem.pronouns.#{gender}")
      Hash[pronouns.map{|k,v| ["pronoun_#{k}".to_sym, v]}]
    end

  end
end
