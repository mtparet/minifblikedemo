class HomeController < ApplicationController

    def index


        @oauth_url = MiniFB.oauth_url('205339842914855', 'http://serveur.paret.fr/' + "sessions/create",
                                      :scope=>MiniFB.scopes.join(","))

    end

    def logout
        cookies[:access_token] = nil
        redirect_to :action=>"index"
    end

end
