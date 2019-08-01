require 'oauth'
require 'json'
require 'forwardable'

module JIRA
  class Oauth3loClient < OauthClient

    def initialize(options)
      @options = DEFAULT_OPTIONS.merge(options)
      @consumer = init_oauth_consumer(@options)
    end

    def init_oauth_consumer(_options)
      @options[:request_token_path] = @options[:context_path] + @options[:request_token_path]
      @options[:authorize_path] = @options[:context_path] + @options[:authorize_path]
      @options[:access_token_path] = @options[:context_path] + @options[:access_token_path]
      OAuth::Consumer.new(nil, nil, @options)
    end    

    def make_request(http_method, path, body = '', headers = {})
      headers['Authorization'] = 'Bearer '+@options[:access_token]

      uri = URI(File.join(@options[:site], path))

      # TODO Should use 
      # Consumer#create_http_request rather than the Net::HTTP::Verb

      case http_method
      when :get
        request = Net::HTTP::Get.new(uri,headers)
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          http.request request
        end
      when :delete, :head
        # TODO This won't work right now
        response = access_token.send http_method, path, headers
      when :post, :put
        request =  Net::HTTP::Post.new(uri,headers)
        request.body = body
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          http.request request
        end
      end
      @authenticated = true
      response

    end

  end
end