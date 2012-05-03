class SessionsController < ApplicationController
    def create
        puts 'sessions/create'
        p params

        code = params['code'] # Facebooks verification string
        if code
            access_token_hash = MiniFB.oauth_access_token('205339842914855', 'http://serveur.paret.fr/' + "sessions/create", '889371f14fd8bdb56175bc5cf9df1914', code)
            p access_token_hash
            @access_token = access_token_hash["access_token"]
            
            profil = MiniFB.get(@access_token, "me", :type=>nil)
            
            #if user doesn't exist in databse, we create this
            if User.where(:fb_id => profil["id"]).first.nil? then

              me = User.find_or_create_by_fb_id(:fb_id => profil["id"])
              me.name = profil["name"]
              me.access_token = @access_token
              me.username = profil["username"]
              me.save
            end

            cookies[:fb_id] = profil["id"]
            cookies[:access_token] = @access_token
            flash[:success] = "Authentication successful."
        end
        redirect_to :controller => "home"
    end
end
