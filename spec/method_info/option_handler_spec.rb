require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/option_handler'

module MethodInfo
  def suppressing_output
    output = $stdout
    $stdout = File.open('/dev/null', 'w')
    yield
  ensure
    $stdout = output
  end

  describe OptionHandler do
    before do
      OptionHandler.stub!(:puts)
    end

    describe "handle" do
      it "builds an ancestor method structure with the object" do
        mock_object = mock('object')
        AncestorMethodStructure.should_receive(:build).with(mock_object, anything)
        MethodInfo::OptionHandler.handle(mock_object)
      end

      it "passes through regular options when building an ancestor method structure" do
        AncestorMethodStructure.should_receive(:build).with(anything, { :some_key => :some_value })
        MethodInfo::OptionHandler.handle(:foo, { :some_key => :some_value })
      end

      it "does not pass the :format option when building an ancestor method structure" do
        AncestorMethodStructure.should_receive(:build).with(anything, { })
        MethodInfo::OptionHandler.handle(:foo, { :format => :string })
      end

      it "prints the ancestor_method_structure if the :format option is not set" do
        mock_ams = mock('ancestor_method_structure')
        AncestorMethodStructure.stub!(:build).and_return(mock_ams)
        OptionHandler.should_receive(:puts).with(mock_ams)
        MethodInfo::OptionHandler.handle(:foo)
      end

      it "returns the array representation of the ancestor_method_structure if the :format option is :array" do
        mock_ams = mock('ancestor_method_structure')
        AncestorMethodStructure.stub!(:build).and_return(mock_ams)
        mock_array_representation = mock('array representation')
        mock_ams.should_receive(:to_a).and_return mock_array_representation
        MethodInfo::OptionHandler.handle(:foo, {:format => :array}).should == mock_array_representation
      end

      it "returns the string representation of the ancestor_method_structure if the :format option is :string" do
        mock_ams = mock('ancestor_method_structure')
        AncestorMethodStructure.stub!(:build).and_return(mock_ams)
        mock_string_representation = mock('string representation')
        mock_ams.should_receive(:to_s).and_return mock_string_representation
        MethodInfo::OptionHandler.handle(:foo, {:format => :string}).should == mock_string_representation
      end

      it "raises an error if the :format option is not supported" do
        AncestorMethodStructure.stub!(:build)
        lambda { MethodInfo::OptionHandler.handle(:foo, { :format => :unknown }) }.
          should raise_error(ArgumentError,
                             "Unknown value for :format option. Supported values are: nil, :array, :string")
      end
    end
  end
end
