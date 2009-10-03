module Magent
  module Utils
    def self.underscore(word)
      word.to_s.gsub(/::/, '/').
                gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
                gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
    end

    def self.camelize(word)
      word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end
