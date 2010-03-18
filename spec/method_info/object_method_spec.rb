require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/object_method'

module MethodInfo
  module ObjectMethod
    describe "method_info" do
      it "passes the object it was called on to the option handler" do
        @obj = Object.new
        MethodInfo::OptionHandler.should_receive(:handle).with(@obj, anything)
        @obj.method_info
      end

      it "passes its options to the option handler" do
        MethodInfo::OptionHandler.should_receive(:handle).with(anything, { :a => :one, :b => :two })
        Object.method_info(:a => :one, :b => :two)
      end
    end
  end
end
