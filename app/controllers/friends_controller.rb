class FriendsController < ApplicationController
  @@lock_common_likes = Mutex.new
  @@lock_list_friends = Mutex.new

  def index
    #get list of friend of current user
    resp = MiniFB.get(@access_token, "me", :type=> "friends",:fields => ["id","name"] )
    friends = resp["data"]

    #get list of my likes
    resp = MiniFB.get(@access_token, "me", :type=> "likes")
    hash_likes_me = resp["data"]

    #friends and common likes

    #array, for all common likes and friend [like,[friend,friend]][like,[friend,friend..
    @common_likes_all = []

    #array, for each friend the like : [friend, [like, like..]][friend, [like, like...
    @list_friends = []

    #All queries about friends' likes
    queries = []
  
    #construct queries for all friends
    friends.each do |friend|
      queries << {:method => 'GET', :relative_url => "#{friend["id"]}/likes?field=id"}
    end
  
    #queries and friends group by 50
    queries_by_50 = []
    friends_by_50 = []
    
    while queries.present? do
      queries_by_50 << queries.slice!(0,50)
      friends_by_50 << friends.slice!(0,50)
    end

    threads = []
    #start request facebook API
    queries_by_50.each do |queries|

    threads << Thread.new do
      friends = friends_by_50[queries_by_50.index queries]

      route = "https://graph.facebook.com/?access_token=#{@access_token}&batch=#{URI.encode(queries.to_json)}"
  
     rep = HTTParty.post(route)
   
      #loop on friends in the response
      rep.each do |one_rep|

        friend = friends[rep.index one_rep]

        unless one_rep["body"].blank?
          likes = JSON.parse(one_rep["body"])
          unless likes["data"].blank?

            #array of likes_id
            list_likes_id = likes["data"].map{|one_like| one_like["id"].to_i }

            #common likes for this friend
            common_likes = []

            #loop to test if there are common likes
            hash_likes_me.each do |hash_like|
              if list_likes_id.include?(hash_like["id"].to_i)

               #then we add it to array 
               common_likes << hash_like

               common_likes_all_id = @common_likes_all.map{ |v| v[:like]}

               #look if thi like is in common_likes_all and get this index
               index = common_likes_all_id.index hash_like

              @@lock_common_likes.synchronize {
                 #test if this like is already in common_likes
                 if index.nil?
                    #so we add like and user
                   like_friend = {:like => hash_like, :friends => [friend]}
                   @common_likes_all << like_friend
                 else
                    #we add only friend in existing array
                   @common_likes_all[index][:friends] << friend
                 end
              }
                  
              end
            end
            friend_like = {:user => friend, :common_likes => common_likes}
            @@lock_list_friends.synchronize{
              #add friend + common_like
              @list_friends << friend_like 
            }  

          end
        end

      end
    end
    end
        threads.each {|t| t.join}

  end
end
