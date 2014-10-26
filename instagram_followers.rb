require 'restclient'
require 'json'

class InstagramBotSearcher
  attr_reader :user_name, :id, :access_tokens
  
  def initialize(username, *tokens)
    @access_tokens = []
    tokens.each do |token|
      @access_tokens << "access_token=#{token}"
    end
    @username = username
    @id = get_id
    @follower_ids = get_follower_ids
  end
  
  def access_token
    @access_tokens.first
  end
    
  def check_followers
    humans = []
    bots = []
    @follower_ids.each do |follower_id|
      p follower_id
      p is_bot?(follower_id)
      if is_bot?(follower_id)
        bots << follower_id
      else
        humans << follower_id
      end
    end
    [humans.count, bots.count]
  end
  
  def get_id
    url = "https://api.instagram.com/v1/users/search?q=[#{@username}]&#{access_token}"
    parsed_response = make_request(url)
    id = parsed_response["data"].first["id"]
  end

  def get_follower_ids
    access_token = @access_tokens.first
    url = "https://api.instagram.com/v1/users/#{@id}/followed-by?#{access_token}"
    ids = []
    while true
      parsed_response = make_request(url)
      break if parsed_response["pagination"]["next_url"].nil?
      parsed_response["data"].each do |follower|
        ids << follower["id"]
      end
      url = parsed_response["pagination"]["next_url"]
      parsed_response = make_request(url)
    end
    ids
  end

  def is_bot?(id)
    url = "https://api.instagram.com/v1/users/#{id}/follows?#{access_token}"
    num_following = 0
    while true
      parsed_response = make_request(url)
      return true unless parsed_response
      break if parsed_response["pagination"]["next_url"].nil?
      num_following += parsed_response["data"].count
      url = parsed_response["pagination"]["next_url"]
      parsed_response = make_request(url)
    end
    num_following > 200
  end
  
  def make_request(url)
    response = RestClient.get(url) do |response, request, result| 
      return false if response.code == 400
      response
    end
    JSON.parse(response)
  end
  
  def result
    pair_followers = check_followers
    puts "#{username} has #{pair_followers[0]} humans and #{pair_followers[1]} bots."
  end
end

access_token = "8413639.1fb234f.c0f10cda7f6e4234bc23be65137d5826"
p = InstagramBotSearcher.new("letisalabufill", access_token)

p.result

