require "net/http"
require "uri"
require "json"

module FirstPass
  module Providers
    class OpenAI < Base
      def review(prompt:)
        key_var = @cfg.dig("provider_env","api_key_var") || "OPENAI_API_KEY"
        api_key = ENV.fetch(key_var)
        model   = @cfg.dig("provider_env","model") || "gpt-4o-mini"
        url     = URI(@cfg.dig("provider_env","api_url") || "https://api.openai.com/v1/chat/completions")

        body = {
          model: model,
          messages: [
            { role: "system", content: "You are a precise code reviewer. Respond ONLY with valid JSON." },
            { role: "user",   content: prompt }
          ],
          temperature: 0.1
        }

        req = Net::HTTP::Post.new(url)
        req["Authorization"] = "Bearer #{api_key}"
        req["Content-Type"]  = "application/json"
        req.body = JSON.dump(body)

        res = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") { |h| h.request(req) }
        json = JSON.parse(res.body)
        content = json.dig("choices",0,"message","content") || "{}"

        begin
          JSON.parse(content)
        rescue JSON::ParserError
          # one retry asking for valid JSON
          body[:messages] << { role: "system", content: "The previous output was not valid JSON. Return only valid JSON now." }
          req.body = JSON.dump(body)
          res = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") { |h| h.request(req) }
          content = JSON.parse(res.body).dig("choices",0,"message","content") || "{}"
          JSON.parse(content)
        end
      end
    end
  end
end
