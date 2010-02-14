require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'method_info'

describe MethodInfo do
  it "defines the method_info method on instances of Object" do
    Object.new.should respond_to(:method_info)
  end
end
