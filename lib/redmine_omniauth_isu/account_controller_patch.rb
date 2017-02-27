module AccountControllerPatch
  def self.included(base)
    base.send(:include, LogoutMethods)
    base.class_eval do
      alias_method_chain :logout, :oauth
    end
  end

  module LogoutMethods
    def logout_with_oauth
      if Setting.plugin_redmine_omniauth_isu[:oauth_authentification]
        logout_user
        redirect_to Setting.plugin_redmine_omniauth_isu[:url]+"/cas/logout"+"?service="+home_url
        return
      end

      return logout_without_oauth # Ruby knows meta-programming, so it just means "logout" :)
    end
  end
end