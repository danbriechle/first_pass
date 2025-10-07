# frozen_string_literal: true
require_relative "first_pass/version"
require_relative "first_pass/config"
require_relative "first_pass/prompt_builder"
require_relative "first_pass/providers/base"
require_relative "first_pass/providers/openai"
require_relative "first_pass/review_runner"
require_relative "first_pass/sarif"
require_relative "first_pass/github"

module FirstPass; end
