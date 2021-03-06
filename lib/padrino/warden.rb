require 'warden'

$:.unshift File.join( File.dirname(__FILE__), '..', '..' )

require 'padrino/warden/version'
require 'padrino/warden/controller'
require 'padrino/warden/helpers'

module Padrino
  module Warden
    def self.registered(app)
      # Enable Sessions
      app.set :sessions, true
      app.set :auth_failure_path, '/'
      app.set :auth_success_path, '/'

      # Setting this to true will store last request URL
      # into a user's session so that to redirect back to it
      # upon successful authentication
      app.set :auth_use_referrer,      false
      app.set :auth_error_message,     "You have provided invalid credentials."
      app.set :auth_success_message,   "You have logged in successfully."
      app.set :deauth_success_message, "You have logged out successfully."
      # Custom map options and layout for the sessions controller
      app.set :auth_login_template,    'sessions/login'
      app.set :auth_login_path,  'sessions/login' unless app.respond_to?(:auth_login_path)
      app.set :auth_unauthenticated_path,'/unauthenticated' unless app.respond_to?(:auth_unauthenticated_path)
      app.set :auth_logout_path,'sessions/logout' unless app.respond_to?(:auth_logout_path)
      app.set :auth_login_layout, true
      # OAuth Specific Settings
      app.set :auth_use_oauth, false
      app.set :default_strategies, [:password] unless app.respond_to?(:default_strategies)

      app.set :warden_failure_app, app
      app.set :warden_default_scope, :session
      app.set(:warden_config) { |manager| nil }
      app.use ::Warden::Manager do |manager|
        manager.scope_defaults :session, strategies: app.default_strategies
        manager.default_scope = app.warden_default_scope
        manager.failure_app   = app.warden_failure_app
        app.warden_config manager
      end

      Controller.registered app
      app.helpers Helpers
    end
  end
end
