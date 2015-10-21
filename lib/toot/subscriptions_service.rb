module Toot
  class SubscriptionsService

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      json = parse_body_json(request)

      if json["channel"] && json["callback_url"]
        Toot.redis do |r|
          r.sadd json["channel"], json["callback_url"]
        end
      else
        response.status = 422
      end

      response.finish
    end

    def self.call(env)
      new.call(env)
    end

    private def parse_body_json(request)
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      {}
    end

  end
end
