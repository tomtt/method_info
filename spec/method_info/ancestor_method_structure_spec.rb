require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/ancestor_method_structure'

module MethodInfo
  describe AncestorMethodStructure do
    describe "class" do
      it "should have specs"
    end

    describe "AncestorMethodStructure::build" do
      it "should print the methods on an object" do
      end
    end

    describe "method_owner" do
      it "gets the method from the object" do
        obj = Object.new
        obj.should_receive(:method).with(:to_s).and_return(mock('method', :owner => nil))
        ams = AncestorMethodStructure.new(obj,
                                          :ancestors_to_show => [],
                                          :ancestors_to_exclude => [])
        ams.send(:method_owner, :to_s)
      end

      describe "for ruby >= 1.8.7" do
        it "gets the owner of the method and returns it" do
          obj = mock('object')
          mock_method = mock('method')
          obj.stub!(:method).and_return(mock_method)
          mock_method.should_receive(:owner).and_return :foo
          ams = AncestorMethodStructure.new(obj,
                                            :ancestors_to_show => [],
                                            :ancestors_to_exclude => [])
          ams.send(:method_owner, :to_s).should == :foo
        end
      end

      describe "for ruby 1.8.6" do
        it "should use the poor_mans_method_owner" do
          obj = mock('object')
          mock_method = mock('method', :to_s => 'mock_method_name')
          obj.stub!(:method).and_return(mock_method)
          mock_method.stub!(:owner).and_raise NameError
          ams = AncestorMethodStructure.new(obj,
                                            :ancestors_to_show => [],
                                            :ancestors_to_exclude => [])
          ams.should_receive(:poor_mans_method_owner).with(mock_method, "to_i")
          ams.send(:method_owner, :to_i)
        end

        it "raises an error if an error is raised that is not a NameError" do
          obj = mock('object')
          mock_method = mock('method', :to_s => 'mock_method_name')
          obj.stub!(:method).and_return(mock_method)
          mock_method.stub!(:owner).and_raise ArgumentError
          ams = AncestorMethodStructure.new(obj,
                                            :ancestors_to_show => [],
                                            :ancestors_to_exclude => [])
          lambda { ams.send(:method_owner, :to_i) }.should raise_error(ArgumentError)
        end

        describe "poor_mans_method_owner" do
          it "finds the owner if it is the base clas" do
            ams = AncestorMethodStructure.new(37, {})
            ams.send(:poor_mans_method_owner, 37.method(:rdiv), "rdiv").should == Fixnum
          end

          it "finds the owner if it is a super clas" do
            ams = AncestorMethodStructure.new(37, {})
            ams.send(:poor_mans_method_owner, 37.method(:ceil), "ceil").should == Integer
          end

          it "finds the owner if it is a module" do
            ams = AncestorMethodStructure.new(37, {})
            ams.send(:poor_mans_method_owner, 37.method(:prec), "prec").should == Precision
          end

          it "finds the owner if it is the eigenclass" do
            obj = Object.new
            def obj.foo
              :foo
            end
            ams = AncestorMethodStructure.new(obj, :singleton_methods => true)
            ams.send(:poor_mans_method_owner, obj.method(:foo), "foo").should == class << obj; self; end
          end
        end
      end
    end
  end
end
