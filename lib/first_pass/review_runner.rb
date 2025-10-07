require "json"
require "fileutils"

module FirstPass
  class ReviewRunner
    def initialize(cfg_path:, base_sha:, head_sha:, pr_title:, pr_body:, repo:, pr_number: nil)
      @cfg = Config.load(cfg_path)
      @base, @head = base_sha, head_sha
      @pr_title, @pr_body = pr_title, pr_body
      @repo, @pr_number = repo, pr_number
    end

    def run
      files = `git diff --name-only #{@base}...#{@head}`.split("\n")
      diff  = `git diff --unified=3 #{@base}...#{@head}`

      prompt = PromptBuilder.new(cfg: @cfg).build(
        pr_title: @pr_title,
        pr_body:  @pr_body,
        files_list: files,
        diff: diff,
        linter: "",
        tests: ""
      )

      provider = FirstPass::Providers::OpenAI.new(cfg: @cfg)
      review = provider.review(prompt: prompt)

      write_artifacts(review)
      post_summary_comment(review)
      enforce_policy(review)
    end

    def write_artifacts(review)
      FileUtils.mkdir_p(File.dirname(@cfg.dig("output","review_json")))
      File.write(@cfg.dig("output","review_json"), JSON.pretty_generate(review))
      if @cfg.dig("output","sarif")
        sarif = Sarif.from_review(review)
        File.write(@cfg.dig("output","sarif"), JSON.pretty_generate(sarif))
      end
    end

    def post_summary_comment(review)
      return unless @cfg.dig("comment","post_to_github") && @pr_number
      gh = GitHub.new(repo: @repo, pr_number: @pr_number)
      gh.post_comment(format_summary(review))
    end

    def enforce_policy(review)
      if @cfg.dig("policy","fail_on_high")
        any_high = (review["findings"] || []).any? { |f| f["severity"] == "HIGH" }
        exit(1) if any_high
      end
    end

    private

    def format_summary(review)
      lines = ["**first_pass summary**", "", review["overall_summary"].to_s]
    
      (review["findings"] || [])[0, 12].each do |f|
        lines << "- **#{f['severity']} / #{f['category']}** — #{f['title']} (#{f['file']}:#{f['line'] || '?'})"
      end
    
      lines << "\n_Artifacts_: `#{@cfg.dig('output', 'review_json')}`" +
               (@cfg.dig('output', 'sarif') ? ", `#{@cfg.dig('output', 'sarif')}`" : "")
    
      lines.join("\n")
      end
    end
end
