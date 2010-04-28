require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/warn_for_old_ruby_version'

module MethodInfo
  describe WarnForOldRubyVersion do
    describe ".warn_if_method_owner_not_supported" do
      before do
        @mock_method = mock('method')
        WarnForOldRubyVersion.stub!(:method).and_return @mock_method
      end

      context "if a Method does not support the :owner method" do
        before do
          @mock_method.stub!(:respond_to?).and_return false
        end

        it "should print a warning message" do
          STDERR.should_receive :puts
          WarnForOldRubyVersion.warn_if_method_owner_not_supported
        end
      end

      context "if a Method supports the :owner method" do
        before do
          @mock_method.stub!(:respond_to?).and_return true
        end

        it "should not print a warning message" do
          STDERR.should_not_receive :puts
          WarnForOldRubyVersion.warn_if_method_owner_not_supported
        end
      end
    end
  end
end
