require "json"

module FirstPass
  class Sarif
    def self.from_review(review)
      results = (review["findings"] || []).map do |f|
        {
          ruleId: (f["rule_id"] || f["category"]),
          level: level_for(f["severity"]),
          message: { text: "#{'#{'}f["title"]}: #{'#{'}f["recommendation"]}" },
          locations: [
            {
              physicalLocation: {
                artifactLocation: { uri: f["file"] },
                region: (f["line"] ? { startLine: f["line"].to_i } : nil)
              }
            }
          ].compact
        }
      end

      {
        version: "2.1.0",
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        runs: [{ tool: { driver: { name: "first_pass" } }, results: results }]
      }
    end

    def self.level_for(sev)
      case sev
      when "HIGH"   then "error"
      when "MEDIUM" then "warning"
      else                 "note"
      end
    end
  end
end
