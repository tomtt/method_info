require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/ancestor_method_mapping'

class HierarchyTop
  def apes; end
  def bears; end
  def cats; end
end

class HierarchyMedium < HierarchyTop
  def apes; end
  def bears; end
end

class HierarchyLow < HierarchyMedium
  def apes; end
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
        def object.method; end
        AncestorMethodMapping.new(object)[:respond_to?].should == Kernel
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
  end
end
