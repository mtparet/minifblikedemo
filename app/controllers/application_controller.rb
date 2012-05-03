class ApplicationController < ActionController::Base
 helper :all # include all helpers, all the time

  protect_from_forgery
  
      before_filter :user_stuff

    def user_stuff
        @access_token = cookies[:access_token]
        @logged_in = @access_token.present? 

        if @logged_in then
          @me = User.where(:fb_id => cookies[:fb_id]).first
          @picture_me_url = "https://graph.facebook.com/" + @me.username + "/picture"
        end
    end
end
