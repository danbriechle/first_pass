module FirstPass
  module Providers
    class Base
      def initialize(cfg:); @cfg = cfg; end
      def review(prompt:); raise NotImplementedError; end
    end
  end
end
