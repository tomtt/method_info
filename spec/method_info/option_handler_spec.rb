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
      describe "processing options" do
        it "raises an argument error when an unsupported option is passed" do
          lambda { MethodInfo::OptionHandler.handle(:object, :unknown_option => :one) }.
            should raise_error(ArgumentError)
        end

        it "raises an error mentioning any unsupported options, ordered alphabetically" do
          lambda { MethodInfo::OptionHandler.handle(:object, :unknown_option => :one, :another => :two) }.
            should raise_error(ArgumentError, "Unsupported options: another, unknown_option")
        end

        it "uses a value from the default profile if an option was not passed" do
          MethodInfo::OptionHandler.stub!(:default_profile).and_return({ :mock_option, :mock_value })
          AncestorMethodStructure.should_receive(:build).with(anything, hash_including(:mock_option => :mock_value))
          MethodInfo::OptionHandler.handle(:object)
        end
        it "uses a value for an option if it was passed in" do
          MethodInfo::OptionHandler.stub!(:default_profile).and_return({ :mock_option, :mock_value })
          AncestorMethodStructure.should_receive(:build).with(anything, hash_including(:mock_option => :passed_value))
          MethodInfo::OptionHandler.handle(:object, :mock_option => :passed_value)
        end

        it "has the correct default values for options" do
          default_options = MethodInfo::OptionHandler.default_profile
          default_options[:format].should == nil
          default_options[:ancestors_to_show].should == []
          default_options[:ancestors_to_exclude].should == []
          default_options[:include_names_of_excluded_ancestors].should == true
          default_options[:include_names_of_methodless_ancestors].should == true
          default_options[:public_methods].should == true
          default_options[:singleton_methods].should == true
          default_options[:protected_methods].should == false
          default_options[:private_methods].should == false
          default_options[:enable_colors].should == false
        end
      end

      it "builds an ancestor method structure with the object" do
        mock_object = mock('object')
        AncestorMethodStructure.should_receive(:build).with(mock_object, anything)
        MethodInfo::OptionHandler.handle(mock_object)
      end

      it "passes through regular options when building an ancestor method structure" do
        AncestorMethodStructure.should_receive(:build).with(anything, hash_including(:private_methods => :some_value))
        MethodInfo::OptionHandler.handle(:foo, { :private_methods => :some_value })
      end

      it "does not pass the :format option when building an ancestor method structure" do
        AncestorMethodStructure.should_receive(:build).with(anything, hash_not_including(:format))
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

    describe "setting default options" do
      it "uses a value that is set in the default options" do
        MethodInfo::OptionHandler.default_options = {
          :ancestors_to_exclude => [Object]
        }
        AncestorMethodStructure.
          should_receive(:build).
          with(anything, hash_including(:ancestors_to_exclude => [Object]))
        MethodInfo::OptionHandler.handle(:foo)
      end
    end

    it "provides access to it's default options" do
      MethodInfo::OptionHandler.default_options[:foo] = :bar
      MethodInfo::OptionHandler.default_options.should == { :foo => :bar }
    end
  end
end
