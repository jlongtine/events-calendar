# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_event_calendar_session',
  :secret      => '66016525abe8f8922deda4500da956bd78c869146b39073986a2448f64100fcb4d8b6941dd9cd7ff8ede27a5b0affae1c485a55256626bc54492cde1dfcaedac'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
