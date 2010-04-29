require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/ancestor_method_mapping'

class HierarchyTop
  def apes; end
  def bears; end
  def cats; end

  protected

  def polarbears; end
end

class HierarchyMedium < HierarchyTop
  def apes; end
  def bears; end

  private

  def penguins; end

  protected

  def polarbears; end
end

class HierarchyLow < HierarchyMedium
  def apes; end

  private

  def penguins; end
end

module MethodInfo

  describe AncestorMethodMapping do
    describe "when finding the owner of a method" do
      context "the ancestor_method_mapping of an object of type HierarchyLow" do
        subject { AncestorMethodMapping.new(HierarchyLow.new) }

        it "should have the HierarchyLow class as the owner of a method that it first defines" do
          subject[:apes].should == HierarchyLow
        end

        it "should have the HierarchyMedium class as the owner of a method that it first defines" do
          subject[:bears].should == HierarchyMedium
        end

        it "should have the HierarchyTop class as the owner of a method that it first defines" do
          subject[:cats].should == HierarchyTop
        end

        it "should have the HierarchyLow class as the owner of a private method that it first defines" do
          subject[:penguins].should == HierarchyLow
        end

        it "should have the HierarchyMedium class as the owner of a protected method that it first defines" do
          subject[:polarbears].should == HierarchyMedium
        end
      end

      it "should have the eigenclass as the owner of a method that is defined on the object" do
        object = HierarchyLow.new
        eigenclass = class << object;self;end
        def object.apes; end
        AncestorMethodMapping.new(object)[:apes].should == eigenclass
      end

      it "should have Kernel as the owner of a method that it defines on any object" do
        object = Object.new
        AncestorMethodMapping.new(object)[:respond_to?].should == Kernel
      end

      it "should still find the owner of a method of an object that defines the method method" do
        object = Object.new
        def object.method
          raise "I do not want to call this method"
        end
        AncestorMethodMapping.new(object)[:respond_to?].should == Kernel
      end

      describe "for ruby versions not supporting Method#owner" do
        it "should use the poor_mans_method_owner" do
          # This is very implementation specific trickery to check that the owner of the method
          # is found using the private poor_mans_method_owner method.
          mock_method = mock('method', :to_s => '#<Method: String#foo>')
          mock_method.stub!(:bind).and_return mock_method
          mock_method.stub!(:call).and_return mock_method
          mock_method.stub!(:owner).and_raise NoMethodError

          Object.stub!(:instance_method).with(:method).and_return mock_method

          object = "a string"
          object.stub!(:methods).and_return([:foo])

          mapping = AncestorMethodMapping.new(object)
          mapping[:foo].should == String
        end

        it "raises an error if an error is raised that is not a NameError" do
          mock_method = mock('method', :to_s => '#<Method: String#foo>')
          mock_method.stub!(:bind).and_return mock_method
          mock_method.stub!(:call).and_return mock_method
          mock_method.stub!(:owner).and_raise StandardError

          Object.stub!(:instance_method).with(:method).and_return mock_method

          object = "a string"
          object.stub!(:methods).and_return([:foo])

          lambda { AncestorMethodMapping.new(object) }.should raise_error(StandardError)
        end

        describe "poor_mans_method_owner" do
          it "finds the owner if it is the base clas" do
            mapping = AncestorMethodMapping.new(37)
            mapping.send(:poor_mans_method_owner, 37.method(:abs), "abs").should == Fixnum
          end

          it "finds the owner if it is a super clas" do
            mapping = AncestorMethodMapping.new(37)
            mapping.send(:poor_mans_method_owner, 37.method(:ceil), "ceil").should == Integer
          end

          it "finds the owner if it is a module" do
            mapping = AncestorMethodMapping.new(37)
            mapping.send(:poor_mans_method_owner, 37.method(:is_a?), "is_a?").should == Kernel
          end

          it "finds the owner if it is the eigenclass" do
            obj = Object.new
            def obj.foo
              :foo
            end
            mapping = AncestorMethodMapping.new(obj)
            eigenclass = class << obj; self; end
            mapping.send(:poor_mans_method_owner, obj.method(:foo), "foo").should == eigenclass
          end

          it "finds the owner if it is nested" do
            pending "Spec needs to be fixed to work with 1.9.1" if RUBY_VERSION >= "1.9.1"
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

            mapping = AncestorMethodMapping.new(obj)
            mapping.send(:poor_mans_method_owner, obj.method(:nest), "nest").should ==
              MethodInfo::TestNestOne::TestNestTwo
          end

          it "finds the owner if it is an anonymous module" do
            anon = Module.new
            anon.send(:define_method, :bla) { :bla }
            class UsingAnonymous
            end
            UsingAnonymous.send(:include, anon)
            obj = UsingAnonymous.new

            mapping = AncestorMethodMapping.new(obj)
            mapping.send(:poor_mans_method_owner, obj.method(:bla), "bla").should == anon
          end
        end
      end
    end

    context "when finding the ancestor hierarchy of an object" do
      before do
        @object = HierarchyLow.new
      end

      subject { AncestorMethodMapping.new(@object) }

      it "should include the eigenclass" do
        eigenclass = class << @object;self;end
        subject.ancestors.should include(eigenclass)
      end
      it "should include its class after its eigenclass" do
        eigenclass = class << @object;self;end
        subject.ancestors.index(HierarchyLow).should >
          subject.ancestors.index(eigenclass)
      end
      it "should include its super-class after its class" do
        subject.ancestors.index(HierarchyMedium).should >
          subject.ancestors.index(HierarchyLow)
      end
      it "should include its super-super-class after its super-class" do
        subject.ancestors.index(HierarchyTop).should >
          subject.ancestors.index(HierarchyMedium)
      end
      it "should include the Kernel module after its classes" do
        subject.ancestors.index(Kernel).should >
          subject.ancestors.index(HierarchyTop)
      end
    end

    context "when finding the ancestor hierarchy of nil" do
      subject { AncestorMethodMapping.new(@object) }

      it "should not have any duplicates" do
        # nil's class and eigenclass are both NilClass
        subject.ancestors.should == subject.ancestors.uniq
      end
    end

    it "should not blow up when finding the ancestor hierarchy of an object with no eigenclass" do
      lambda { AncestorMethodMapping.new(5) }.should_not raise_error
    end
  end
end
