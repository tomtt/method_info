require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/ancestor_list'

module MethodInfo
  describe AncestorList do
    describe "AncestorList::build" do
    end

    describe "process options" do
      it "raises an argument error when an unsupported option is passed" do
        lambda { AncestorList.send(:process_options, :unknown_option => :one) }.
          should raise_error(ArgumentError)
      end

      it "raises an error mentioning any unsupported options, ordered alphabetically" do
        lambda { AncestorList.send(:process_options, :unknown_option => :one, :another => :two) }.
          should raise_error(ArgumentError, "Unsupported options: another, unknown_option")
      end

      it "uses the value passed in for the :method option" do
        parsed_options = AncestorList.send(:process_options, :method => :one)
        parsed_options[:method].should == :one
      end

      it "uses the default value (nil) if no :method option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:method].should be_nil
      end

      it "uses the value passed in for the :ancestors_to_show option" do
        parsed_options = AncestorList.send(:process_options, :ancestors_to_show => [Object])
        parsed_options[:ancestors_to_show].should == [Object]
      end

      it "uses a false value passed in for the :ancestors_to_show option" do
        parsed_options = AncestorList.send(:process_options, :ancestors_to_show => false)
        parsed_options[:ancestors_to_show].should == false
      end

      it "uses the default value ([]) if no :ancestors_to_show option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:ancestors_to_show].should == []
      end

      it "uses the value passed in for the :ancestors_to_exclude option" do
        parsed_options = AncestorList.send(:process_options, :ancestors_to_exclude => [Object])
        parsed_options[:ancestors_to_exclude].should == [Object]
      end

      it "uses the default value ([]) if no :ancestors_to_exclude option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:ancestors_to_exclude].should == []
      end

      it "uses the value passed in for the :method_missing option" do
        parsed_options = AncestorList.send(:process_options, :method_missing => true)
        parsed_options[:method_missing].should == true
      end

      it "uses the default value (false) if no :method_missing option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:method_missing].should == false
      end

      it "uses the value passed in for the :public_methods option" do
        parsed_options = AncestorList.send(:process_options, :public_methods => false)
        parsed_options[:public_methods].should == false
      end

      it "uses the default value (true) if no :public_methods option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:public_methods].should == true
      end

      it "uses the value passed in for the :protected_methods option" do
        parsed_options = AncestorList.send(:process_options, :protected_methods => true)
        parsed_options[:protected_methods].should == true
      end

      it "uses the default value (false) if no :protected_methods option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:protected_methods].should == false
      end

      it "uses the value passed in for the :private_methods option" do
        parsed_options = AncestorList.send(:process_options, :private_methods => true)
        parsed_options[:private_methods].should == true
      end

      it "uses the default value (false) if no :private_methods option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:private_methods].should == false
      end

      it "uses the value passed in for the :include_name_of_excluded_ancestors option" do
        parsed_options = AncestorList.send(:process_options, :include_name_of_excluded_ancestors => false)
        parsed_options[:include_name_of_excluded_ancestors].should == false
      end

      it "uses the default value (true) if no :include_name_of_excluded_ancestors option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:include_name_of_excluded_ancestors].should == true
      end

      it "uses the value passed in for the :format option" do
        parsed_options = AncestorList.send(:process_options, :format => :yaml)
        parsed_options[:format].should == :yaml
      end

      it "uses the default value (:string) if no :format option was passed" do
        parsed_options = AncestorList.send(:process_options)
        parsed_options[:format].should == :string
      end
    end
  end
end
