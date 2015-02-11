class Activity < ActiveRecord::Base

  STRING_FIELDS = [:language, :present_indicative, :present_particple, :past_participle, :noun, :short_noun]

  STRING_FIELDS.each{|x| validates x, presence: true, length: { maximum: 255 } }

end
