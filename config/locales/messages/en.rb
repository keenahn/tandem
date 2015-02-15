# Text message translations
{
  en: {
    activities: {
      meditation: {
        present_particple: "meditating",
        infinitive: "to meditate",
        past: "meditated",
        simple_present: "meditate",
        noun: "meditation",
        short_noun: "'tate"
      },
    },

    pronouns: {
      masculine_subject: "he",
      masculine_object: "him",
      feminine_subject: "she",
      feminine_object: "her"
    },

    messages: {
      am_or_pm: "AM or PM?",
      bad_time: "Sorry, didn't understand that. If you want to reschedule, reply like this example: reschedule 4:36 PM. Thanks!",
      no_response_both_first_time: "Okay guys, looks like neither of you %{activity_past}. But you still can! Reply 'yes' and we'll tell your buddy. Reply with anything else to send a message.\nYou can also reply 'reschedule X:XX am [or pm]' to set a new check-in for today.",
      no_response_both_post_second_time: "Okay guys, looks like neither of you %{activity_past}. You can still do it and reply 'yes' to tell your buddy. You can also reschedule.",
      no_response_both_second_time: "Okay guys, looks like neither of you %{activity_past}. No biggie, you can still do it and reply 'yes' to tell your buddy.\nYou can also reschedule ('reschedule X:XX am').",
      no_response_doer: "You didn't reply 'yes' in 15 minutes, so we had to tell %{helper_first_name} you didn't %{activity_simple_present}. But you can still do it. Reply 'yes' and we'll let %{helper_pronoun_object} know!\nYou can also reply 'reschedule X:XX am [or pm]' to set a new check-in for today.",
      no_response_doer_first_time: "You didn't reply 'yes' in 15 minutes, so we had to tell %{helper_first_name} you didn't %{activity_simple_present}. But you can still do it. Reply 'yes' and we'll let %{helper_pronoun_object} know!\nYou can also reply 'reschedule X:XX am [or pm]' to set a new time for today.",
      no_response_doer_post_second_time: "That was 15 minutes, so we had to tell %{helper_first_name} you didn't %{activity_simple_present}. But you can still do it and reply 'yes' to tell %{helper_first_name}! You can also reschedule.",
      no_response_doer_second_time: "That was 15 minutes, so we had to tell %{helper_first_name} you didn't %{activity_simple_present}. But you can still do it and reply 'yes' to tell %{helper_first_name}!\nYou can also reschedule ('reschedule X:XX am').",
      no_response_helper: "%{doer_first_name} didn't %{activity_simple_present} yet, but you can still send %{helper_pronoun_object} encouragement by replying to this text! And tomorrow's another day!",
      no_response_helper_first_time: "%{doer_first_name} didn't %{activity_simple_present} yet. But %{doer_pronoun_subject} still can, so send %{doer_pronoun_subject} encouragement by replying to this text!",

      yes_response_doer: {
        0  => "Awesome! We told %{helper_first_name} you did it!",
        1  => "Awesome! We let %{helper_first_name} know you did it!",
        2  => "Awesome! We told %{helper_first_name}!",
        3  => "Awesome! We let %{helper_first_name} know!",
        4  => "Awesome! We told %{helper_first_name} you're %{activity_present_particple}!",
        5  => "Awesome! We let %{helper_first_name} know you're %{activity_present_particple}!",
        6  => "Sweet! We told %{helper_first_name} you did it!",
        7  => "Sweet! We let %{helper_first_name} know you did it!",
        8  => "Sweet! We told %{helper_first_name}!",
        9  => "Sweet! We let %{helper_first_name} know!",
        10 => "Sweet! We told %{helper_first_name} you're %{activity_present_particple}!",
        11 => "Sweet! We let %{helper_first_name} know you're %{activity_present_particple}!",
        12 => "Nice! We told %{helper_first_name} you did it!",
        13 => "Nice! We let %{helper_first_name} know you did it!",
        14 => "Nice! We told %{helper_first_name}!",
        15 => "Nice! We let %{helper_first_name} know!",
        16 => "Nice! We told %{helper_first_name} you're %{activity_present_particple}!",
        17 => "Nice! We let %{helper_first_name} know you're %{activity_present_particple}!",
        18 => "Booya! We told %{helper_first_name} you did it!",
        19 => "Booya! We let %{helper_first_name} know you did it!",
        20 => "Booya! We told %{helper_first_name}!",
        21 => "Booya! We let %{helper_first_name} know!",
        22 => "Booya! We told %{helper_first_name} you're %{activity_present_particple}!",
        23 => "Booya! We let %{helper_first_name} know you're %{activity_present_particple}!",
        24 => "Nice one.",
        25 => "Cool. We're letting %{helper_first_name} know."
      } # close yes_response_doer
    } # close messages
  } # close en
} # close all
