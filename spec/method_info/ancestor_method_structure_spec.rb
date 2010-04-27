require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/ancestor_method_structure'

module MethodInfo
  describe AncestorMethodStructure do
    it "lists the methods defined in a class as owned by that class" do
      class LocalTest
        def foo; end
        def bar; end
        def self.baz; end
      end
      local_test = LocalTest.new
      ams = AncestorMethodStructure.new(local_test)
      methods_owned_by_local_test = ams.structure[LocalTest]
      methods_owned_by_local_test.should include(:foo, :bar)
      methods_owned_by_local_test.size.should == 2
    end

    it "lists methods defined by Kernel as owned by Kernel" do
      object = Object.new
      ams = AncestorMethodStructure.new(object)
      methods_owned_by_kernel = ams.structure[Kernel]
      methods_owned_by_kernel.should include(:inspect, :clone, :respond_to?)
    end

    context "within an ancestor hierarchy" do
      class HierarchyTop
        def apes; end
        def bears; end
        def cats; end
      end

      class HierarchyMedium < HierarchyTop
        def apes; end
        def bears; end
      end

      class HierarchyLower < HierarchyMedium
        def apes; end
      end

      before do
        @hier = HierarchyLower.new
        @ams = AncestorMethodStructure.new(@hier)
        @structure = @ams.structure
      end

      it "lists methods owned by all ancestors as owned by the 'first' one" do
        @structure[HierarchyLower].should == [:apes]
      end

      it "lists methods owned by only the higher ancestors as owned by the 'first' one" do
        @structure[HierarchyMedium].should == [:bears]
      end

      it "lists methods owned by only the highest ancestors" do
        @structure[HierarchyTop].should == [:cats]
      end
    end
  end
end
