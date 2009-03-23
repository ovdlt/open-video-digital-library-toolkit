# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_2.3_session',
  :secret      => '40fccb0e178f0be8568eecdd5d214e127d6f0fa24dc5011abd3f36aa047b05232f262b8405d029013f7b3a877d240ad19bdc15433f63dda2e8b64a595c2b0486'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
