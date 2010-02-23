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
      it "gets the owner of the method and returns it" do
        ams = AncestorMethodStructure.new(5,
                                          :ancestors_to_show => [],
                                          :ancestors_to_exclude => [])
        ams.send(:method_owner, :ceil).should == Integer
      end

      it "can still return the owner of the method if the object has redefined :method" do
        class MethodRedefinedTestClass
          def method
            raise "I do not want to call this method"
          end

          def foo
            :foo
          end
        end
        obj = MethodRedefinedTestClass.new

        ams = AncestorMethodStructure.new(obj,
                                          :ancestors_to_show => [],
                                          :ancestors_to_exclude => [])
        ams.send(:method_owner, :foo).should == MethodRedefinedTestClass
      end

      describe "for ruby 1.8.6" do
        it "should use the poor_mans_method_owner" do
          mock_method = mock('method', :to_s => 'mock_method_name')
          mock_method.stub!(:bind).and_return mock_method
          mock_method.stub!(:call).and_return mock_method

          mock_method.stub!(:owner).and_raise NameError

          Object.stub!(:instance_method).with(:method).and_return mock_method
          ams = AncestorMethodStructure.new(5,
                                            :ancestors_to_show => [],
                                            :ancestors_to_exclude => [])
          ams.should_receive(:poor_mans_method_owner).with(mock_method, "dup")
          ams.send(:method_owner, :dup)
        end

        it "raises an error if an error is raised that is not a NameError" do
          mock_method = mock('method', :to_s => 'mock_method_name')
          mock_method.stub!(:bind).and_return mock_method
          mock_method.stub!(:call).and_return mock_method

          mock_method.stub!(:owner).and_raise StandardError

          Object.stub!(:instance_method).with(:method).and_return mock_method
          ams = AncestorMethodStructure.new(5,
                                            :ancestors_to_show => [],
                                            :ancestors_to_exclude => [])

          lambda { ams.send(:method_owner, :to_i) }.should raise_error(StandardError)
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

          it "finds the owner if it is nested" do
            module TestNestOne
              module TestNestTwo
                def nest
                  :nest
                end
              end
            end

            class TestNest
              include TestNestOne::TestNestTwo
            end
            obj = TestNest.new

            ams = AncestorMethodStructure.new(obj, {})
            ams.send(:poor_mans_method_owner, obj.method(:nest), "nest").should == MethodInfo::TestNestOne::TestNestTwo
          end

          it "finds the owner if it is an anonymous module" do
            anon = Module.new
            anon.send(:define_method, :bla) { :bla }
            class UsingAnonymous
            end
            UsingAnonymous.send(:include, anon)
            obj = UsingAnonymous.new

            ams = AncestorMethodStructure.new(obj, {})
            ams.send(:poor_mans_method_owner, obj.method(:bla), "bla").should == anon
          end
        end
      end
    end
  end
end
