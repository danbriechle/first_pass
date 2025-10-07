# first_pass

An LLM-powered **first-pass PR review** you can drop into any repo that leverages an organization’s coding standards 
and internal documentation to perform an initial review before senior engineers are involved. It is designed to help
junior and mid level developers identify small issues, maintain consistency with established practices, and surface relevant
organizational guidance early in the review process. Its purpose is to improve code quality, reduce review overhead,
and strengthen learning and alignment across the engineering team

- Reads **git diff + PR metadata** and your **org standards**
- Emits **JSON** and optional **SARIF**
- Posts a **summary comment** to GitHub PRs
- Optional: fail CI on **HIGH** severity findings

## Install
```bash
bundle add first_pass --path .
# or publish the gem and `bundle add first_pass`
```

## Configure
Copy and edit:
```bash
cp config/first_pass.yml.example config/first_pass.yml
```

## GitHub Actions
Add `.github/workflows/llm-pr-review.yml` (see repo).

## Docs inputs
Point `config/first_pass.yml` to your standards/goals markdown files:
```
docs/engineering/coding-standards.md
docs/engineering/security.md
docs/engineering/documentation.md
docs/engineering/goals.md
```

## Environment
- `OPENAI_API_KEY` (required)
- `GITHUB_TOKEN` (Actions provides automatically)

## Notes
- Sends only the **diff** + small excerpts of your docs to the LLM.
- Keep human review as the final gate; this tool is **advisory** by default.
