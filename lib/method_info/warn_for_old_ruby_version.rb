module MethodInfo
  class WarnForOldRubyVersion
    def self.warn_if_method_owner_not_supported
      unless WarnForOldRubyVersion.ruby_version_supports_owner_method?
        STDERR.puts "You are using a Ruby version (#{RUBY_VERSION}) that does not support the owner method of a Method - this may take a while. It will be faster for >=1.8.7."
      end
    end

    private

    def self.ruby_version_supports_owner_method?
      method(:dup).respond_to?(:owner)
    end
  end
end
