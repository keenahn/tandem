Sms.config.dry_run = false
Sms.config.dry_run = true if Rails.env.staging? || Rails.env.test?
