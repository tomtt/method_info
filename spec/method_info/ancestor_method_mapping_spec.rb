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
end
