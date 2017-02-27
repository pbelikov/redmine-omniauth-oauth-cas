require 'account_controller'
require 'json'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE # comment this line if your OAuth provider has GOOD SSL certificate

ENV["http_proxy"]="" # comment this line if

class RedmineOauthController < AccountController
  include Helpers::MailHelper
  include Helpers::Checker

  # Initialization
  def oauth_isu
    if Setting.plugin_redmine_omniauth_isu[:oauth_authentification]
      session[:back_url] = params[:back_url]
      hash = {:response_type => "code",
              :client_id => settings[:client_id],
              :redirect_uri => oauth_isu_callback_url}
      param_arr = []
      hash.each do |key , val|
        param_arr << "#{key}=#{val}"
      end
      params_str = param_arr.join("&")
      redirect_to settings[:url].gsub(/\/+$/, '') + "/cas/oauth2.0/authorize?#{params_str}"
    else
      password_authentication
    end
  end

  # Token processing
  def oauth_isu_callback
    if params[:error]
      flash[:error] = l(:notice_access_denied)
      redirect_to signin_path
    else
      # Access token
      code = params[:code]
      connection = Faraday::Connection.new settings[:url].gsub(/\/+$/, ''), :ssl => {:verify => false} # comment :ssl part is your certificate is OK
      response = connection.post do |req|
        req.url "/cas/oauth2.0/accessToken"
        req.params["grant_type"] = "authorization_code"
        req.params["client_id"] = settings[:client_id]
        req.params["client_secret"] = settings[:client_secret]
        req.params["code"] = code
        req.params["redirect_uri"] = oauth_isu_callback_url
      end
      token = CGI.parse(response.body)['access_token'][0].to_s
      response = connection.get do |req|
        req.url "/cas/oauth2.0/profile?access_token=#{token}"
      end

      # Profile parse
      info = JSON.parse(response.body)

      # Login
      if info && info["id"]
        try_to_login info["attributes"]
      else
        flash[:error] = l(:notice_unable_to_obtain_isu_credentials)
        redirect_to signin_path
      end
    end
  end

  # Login
  def try_to_login info
   params[:back_url] = session[:back_url]
   session.delete(:back_url)
   # Info is provided as { :redmine_login => "ivan", :redmine_attrs => "Ivan|Ivanov|ivan@example.com" }
   user = User.where(:login => info["redmine_login"]).first_or_create
    if user.new_record?
      # Create on the fly
      user.firstname = info["redmine_attrs"].split("|")[0]
      user.lastname = info["redmine_attrs"].split("|")[1]
      user.mail = info["redmine_attrs"].split("|")[2]
      user.login = info["redmine_login"]
      user.random_password
      user.register

      # Here is some really dirty coding, because we override Redmine registration policies
      user.activate
      user.last_login_on = Time.now
      if user.save
        self.logged_user = user
        flash[:notice] = l(:notice_account_activated)
        redirect_to my_account_path
      else
        yield if block_given?
      end
    else
      # Existing record
      if user.active?
        successful_authentication(user)
      else
        # Redmine 2.4 adds an argument to account_pending
        if Redmine::VERSION::MAJOR > 2 or
          (Redmine::VERSION::MAJOR == 2 and Redmine::VERSION::MINOR >= 4)
          account_pending(user)
        else
          account_pending
        end
      end
    end
  end

  # Settings
  def settings
    @settings ||= Setting.plugin_redmine_omniauth_isu
  end
end