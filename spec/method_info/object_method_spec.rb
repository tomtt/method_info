require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/object_method'

module MethodInfo
  module ObjectMethod
    describe "method_info" do
      before do
        @obj = Object.new
        @obj.stub!(:puts)
      end

      it "creates an AncestorList object for the object it was called on" do
        AncestorList.should_receive(:build).with(@obj, anything)
        @obj.method_info
      end

      it "creates an AncestorList object with no options if none are specified" do
        AncestorList.should_receive(:build).with(anything, {})
        @obj.method_info(options)
      end

      it "creates an AncestorList object with the options passed to it" do
        options = { :ancestors_to_exclude => [Object] }
        AncestorList.should_receive(:build).with(anything, options)
        @obj.method_info(options)
      end

      it "prints the ancestor list if the :print option is passed and true" do
        mock_ancestor_list = mock("ancestor list")
        AncestorList.stub!(:build).and_return(mock_ancestor_list)
        @obj.should_receive(:puts).with(mock_ancestor_list)
        @obj.method_info(:print => true)
      end

      it "does not print the ancestor list if the :print option is passed and false" do
        mock_ancestor_list = mock("ancestor list")
        AncestorList.stub!(:build).and_return(mock_ancestor_list)
        @obj.should_not_receive(:puts).with(mock_ancestor_list)
        @obj.method_info(:print => nil)
      end

      it "prints the ancestor list if the :print option is not passed" do
        mock_ancestor_list = mock("ancestor list")
        AncestorList.stub!(:build).and_return(mock_ancestor_list)
        @obj.should_receive(:puts).with(mock_ancestor_list)
        @obj.method_info
      end

      it "does not pass the :print option when creating the AncestorList" do
        AncestorList.should_receive(:build).with(anything, hash_not_including(:print))
        @obj.method_info(:print => true)
      end

      it "returns the created ancestor list" do
        mock_ancestor_list = mock("ancestor list")
        AncestorList.stub!(:build).and_return(mock_ancestor_list)
        @obj.method_info.should == mock_ancestor_list
      end

    end
  end
end
