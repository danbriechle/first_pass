require_relative "lib/first_pass/version"


Gem::Specification.new do |spec|
  spec.name          = "first_pass"
  spec.version       = FirstPass::VERSION
  spec.authors       = ["Daniel Briechle"]
  spec.email         = ["maintainers@example.com"]

  spec.summary       = "LLM-powered first-pass PR review for GitHub Actions"
  spec.description   = "Advisory PR review that reads diffs and your org standards, emits JSON and optional SARIF, and can comment on PRs."
  spec.license       = "MIT"
  spec.homepage      = "https://github.com/your-org/first_pass"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*", "bin/*", "README.md", "LICENSE", "schema/*.json", "prompts/*.md", "config/*.yml.example", ".github/workflows/*.yml"]
  end
  spec.bindir        = "bin"
  spec.executables   = ["first-pass"]
  spec.require_paths = ["lib"]

  spec.add_dependency "json", ">= 2.6"
end

