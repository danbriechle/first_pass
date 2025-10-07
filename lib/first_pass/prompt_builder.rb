require "json"

module FirstPass
  class PromptBuilder
    def initialize(cfg:, repo_root: Dir.pwd)
      @cfg, @root = cfg, repo_root
    end

    def build(pr_title:, pr_body:, files_list:, diff:, linter: "", tests: "")
      template = File.read(File.join(@root, "prompts", "reviewer.md"))

      replacements = {
        "<<<CODING_STANDARDS>>>"     => excerpt(@cfg.dig("canon","coding_standards")),
        "<<<SECURITY_GUIDELINES>>>"  => excerpt(@cfg.dig("canon","security")),
        "<<<DOC_RULES>>>"            => excerpt(@cfg.dig("canon","documentation")),
        "<<<ENG_GOALS>>>"            => excerpt(@cfg.dig("canon","goals")),
        "<<<LINTER>>>"               => linter.to_s[0, 20_000],
        "<<<TESTS>>>"                => tests.to_s[0, 20_000],
        "<<<PR_TITLE>>>"             => pr_title.to_s,
        "<<<PR_BODY>>>"              => pr_body.to_s,
        "<<<FILES>>>"                => files_list.join("\n"),
        "<<<DIFF>>>"                 => diff.to_s[0, @cfg["max_diff_bytes"] || 300_000]
      }

      prompt = template.dup
      replacements.each { |k,v| prompt.gsub!(k, v || "") }
      prompt
    end

    private

    def excerpt(path)
      return "" unless path && File.exist?(path)
      File.read(path)[0, 50_000]
    end
  end
end
