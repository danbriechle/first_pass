require "net/http"
require "uri"
require "json"

module FirstPass
  class GitHub
    def initialize(repo:, pr_number:, token: ENV["GITHUB_TOKEN"])
      @repo, @pr, @token = repo, pr_number, token
    end

    def post_comment(body)
      url = URI("https://api.github.com/repos/#{@repo}/issues/#{@pr}/comments")
      req = Net::HTTP::Post.new(url)
      req["Authorization"] = "Bearer #{@token}"
      req["Accept"]        = "application/vnd.github+json"
      req["Content-Type"]  = "application/json"
      req.body = JSON.dump({ body: body })
      Net::HTTP.start(url.host, url.port, use_ssl: true) { |h| h.request(req) }
    end
  end
end
