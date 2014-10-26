require 'restclient'
require 'json'

class InstagramBotSearcher
  attr_reader :user_name, :id
  
  def initialize(username)
    @access_token = "access_token=8413639.1fb234f.c0f10cda7f6e4234bc23be65137d5826"
    @username = username
    @id = get_id
    @follower_ids = get_follower_ids
  end
  
  def get_id
    url = "https://api.instagram.com/v1/users/search?q=[#{@username}]&#{@access_token}"
    parsed_response = make_request(url)
    id = parsed_response["data"].first["id"]
  end

  def get_follower_ids
    url = "https://api.instagram.com/v1/users/#{@id}/followed-by?#{@access_token}"
    parsed_response = make_request(url)
    ids = []
    while parsed_response["pagination"]["next_url"]
      parsed_response["data"].each do |follower|
        ids << follower["id"]
      end
      url = parsed_response["pagination"]["next_url"]
      parsed_response = make_request(url)
    end
    ids
  end
  
  def check_followers
    humans = []
    bots = []
    @follower_ids.each do |follower_id|
      p follower_id
      if is_bot?(follower_id)
        bots << follower_id
      else
        humans << follower_id
      end
    end
    humans
  end
  
  def is_bot?(id)
    url = "https://api.instagram.com/v1/users/#{id}/follows?#{@access_token}"
    parsed_response = make_request(url)
    p parsed_response
    num_following = parsed_response["data"].count
    while parsed_response["pagination"]["next_url"]
      num_following += parsed_response["data"].count
      p num_following
      url = parsed_response["pagination"]["next_url"]
      p url
      parsed_response = make_request(url)
    end
    p num_following
  end
  
  def make_request(url)
    response = RestClient.get(url) do |response, request, result| 
      p response.class
      p JSON.parse(response)
      response
    end
    JSON.parse(response)
  end
end

p = InstagramBotSearcher.new("letisalabufill")

p.check_followers

