require "yaml"
require "ostruct"

module FirstPass
  class Config < OpenStruct
    def self.load(path)
      data = YAML.load_file(path)
      new(data)
    end
  end
end
