require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/formatter'

module MethodInfo
  describe Formatter do
    context "with default options" do
      before do
        @object = Object.new
        @formatter = Formatter.build(@object, OptionHandler.process_options({}))
      end

      it "should have specs"
    end
  end
end
