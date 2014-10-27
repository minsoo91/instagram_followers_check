require 'restclient'
require 'json'

class InstagramBotSearcher
  attr_reader :username, :id, :access_tokens
  
  def initialize(username, *tokens)
    @access_tokens = []
    tokens.each do |token|
      @access_tokens << "access_token=#{token}"
    end
    @username = username
    @id = get_id
  end
  
  def access_token
    @access_tokens.first
  end

  def check_followers
    url = "https://api.instagram.com/v1/users/#{@id}/followed-by?#{access_token}"
    valids, not_valids = 0, 0
    while true
      parsed_response = make_request(url)
      parsed_response["data"].each do |follower|
        is_valid?(follower["id"]) ? not_valids += 1 : valids += 1
      end
      break if parsed_response["pagination"]["next_url"].nil?
      url = parsed_response["pagination"]["next_url"]
    end
    [valids, not_valids]
  end
  
  def get_id
    url = "https://api.instagram.com/v1/users/search?q=[#{@username}]&#{access_token}"
    parsed_response = make_request(url)
    parsed_response["data"].first["id"]
  end
  
  def is_valid?(id)
    many_followings?(id)
  end

  def make_request(url)
    response = RestClient.get(url) do |response, request, result| 
      return false if response.code == 400
      response
    end
    JSON.parse(response)
  end
  
  def many_followings?(id)
    num_following(id) > 400
  end

  def num_following(id)
    url = "https://api.instagram.com/v1/users/#{id}/?#{access_token}"
    puts "requesting..."
    parsed_response = make_request(url)
    return 0 unless parsed_response
    parsed_response["data"]["counts"]["follows"]
  end
    
  def result
    pair_followers = check_followers
    puts "#{username} has #{pair_followers[0]} humans and #{pair_followers[1]} bots."
  end
end

access_token = "8413639.1fb234f.c0f10cda7f6e4234bc23be65137d5826"
p = InstagramBotSearcher.new("marinuxi", access_token)

p.result

