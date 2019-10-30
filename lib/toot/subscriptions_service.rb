module Toot
  class SubscriptionsService

    def self.call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      me = new(request, response)

      if me.respond_to?(request.request_method.downcase)
        me.public_send(request.request_method.downcase)
      else
        # Method not allowed
        response.status = 405
      end

      response.finish
    end

    attr_reader :request, :response
    def initialize(request, response)
      @request = request
      @response = response
    end

    def get
      accept = request.env['HTTP_ACCEPT']
      
      if accept.include?('application/json')
        response.header['Content-Type'] = 'application/json'
        response.write({
          channels: channels,
          subscriptions: subscriptions,
        }.to_json)
        return
      end

      response.status = 406
    end

    def post
      json = parse_body_json(request)

      if !json["channel"] || !json["callback_url"]
        response.status = 422
        return
      end

      added = Toot.redis do |r|
        r.sadd json["channel"], json["callback_url"]
      end
      response.status = added ? 201 : 204
    end

    def delete
      channel = request.params['channel']
      callback_url = request.params['callback_url']
      if channel.blank? || callback_url.blank?
        response.status = 400
        return
      end

      result = Toot.redis do |r|
        r.srem channel, callback_url
      end

      response.status = result ? 204 : 404
    end

    private
    
    def parse_body_json(request)
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      {}
    end

    def channels
      @channels ||= Toot.redis { |r| r.keys(Toot.config.channel_prefix + "*") }
    end

    def subscriptions
      @subscriptions ||= channels.each_with_object({}) do |ch, h|
        h[ch] = Toot.redis { |r| r.smembers ch }
      end
    end
  end
end
