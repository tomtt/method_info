require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MethodInfo do
  describe "ancestors" do
    it "has the ancestors that a String has on any system for a String object" do
      ancestors = 37.method_info.ancestors
      usual_ancestors = [Fixnum, Integer, Precision, Numeric, Comparable, Object, Kernel]
      ancestors_without_system_specific_ones = ancestors.
        select { |ancestor| usual_ancestors.include?(ancestor) }
      ancestors_without_system_specific_ones.should == usual_ancestors
    end

    it "does not contain a module that was not included" do
      class Forest
      end
      sherwood = Forest.new
      sherwood.method_info.ancestors.should_not include(Enumerable)
    end

    it "contains an included module" do
      class Zoo
        include(Enumerable)
      end
      artis = Zoo.new
      artis.method_info.ancestors.should include(Enumerable)
    end

    it "has an object's eigenclass as the first element if it has singleton methods" do
      monkey = Object.new
      def monkey.talk
        "Ook!"
      end
      eigenclass_of_monkey = class << monkey; self; end
      monkey.method_info.ancestors.first.should == eigenclass_of_monkey
    end

    it "does not include the object's eigenclass if it has no singleton methods" do
      monkey = Object.new
      eigenclass_of_monkey = class << monkey; self; end
      monkey.method_info.ancestors.should_not include(eigenclass_of_monkey)
    end
  end

  describe "method_owner" do
    class AbstractMethodOwnerDummy
      def abstract_instance_method
        :abstract_instance_method
      end

      def duplicate_instance_method
        :abstract_duplicate_instance_method
      end

      def method_missing(method)
        if method == :missing_method_handled_at_abstract
          return :missing_method_handled_at_abstract
        end
        super
      end
    end

    class ConcreteMethodOwnerDummy < AbstractMethodOwnerDummy
      def concrete_instance_method
        :concrete_instance_method
      end

      def duplicate_instance_method
        :concrete_duplicate_instance_method
      end

      def method_missing(method)
        if method == :missing_method_handled_at_concrete
          return :missing_method_handled_at_concrete
        end
        super
      end
    end

    it "is the class of the object for an instance_method" do
      ConcreteMethodOwnerDummy.new.method_info.method_owner(:concrete_instance_method).should ==
        ConcreteMethodOwnerDummy
    end

    it "is the superclass of an objects class if that is where the method is first defined" do
      ConcreteMethodOwnerDummy.new.method_info.method_owner(:abstract_instance_method).should ==
        AbstractMethodOwnerDummy
    end

    it "raises an error if the object does not respond to the method" do
      lambda { ConcreteMethodOwnerDummy.new.method_info.method_owner(:poof) }.should raise_error(NameError)
    end

    it "raises an error if the method is handled by :method_missing" do
      lambda { ConcreteMethodOwnerDummy.new.method_info.method_owner(:missing_method_handled_at_concrete) }.should raise_error(NameError)
    end

    describe "method_owner!" do
      it "is the class of the object for an instance_method" do
        ConcreteMethodOwnerDummy.new.method_info.method_owner!(:concrete_instance_method).should ==
          ConcreteMethodOwnerDummy
      end

      it "is the superclass of an objects class if that is where the method is first defined" do
        ConcreteMethodOwnerDummy.new.method_info.method_owner!(:abstract_instance_method).should ==
          AbstractMethodOwnerDummy
      end

      it "raises an error if the object does not respond to the method" do
        lambda { ConcreteMethodOwnerDummy.new.method_info.method_owner!(:poof) }.should raise_error(NameError)
      end

      it "is :method_missing if the concrete class handles the method" do
        ConcreteMethodOwnerDummy.new.method_info.method_owner!(:missing_method_handled_at_concrete).should ==
          :method_missing
      end

      it "is :method_missing if the abstract class handles the method" do
        ConcreteMethodOwnerDummy.new.method_info.method_owner!(:missing_method_handled_at_abstract).should ==
          :method_missing
      end

      it "is :method_missing if the object has a method_missing singleton method that handles the method" do
        monkey = Object.new
        def monkey.method_missing(method)
          if method == :missing_method_handled_at_singleton_method
            return :missing_method_handled_at_singleton_method
          end
          super
        end
        monkey.method_info.method_owner!(:missing_method_handled_at_singleton_method).should ==
          :method_missing
      end

      it "does not modify an object whose method_missing has side effects" do
        monkey = Object.new
        monkey.instance_eval { @hair = "brown" }
        def monkey.method_missing(method)
          @hair = "blue"
        end
        monkey.method_info.method_owner!(:unknown_method)
        monkey.instance_eval('@hair').should == "brown"
      end

      # Undesirable behaviour, but I don't think there is an easy way around it
      it "will not protect an object's objects from method_missing side effects" do
        monkey = Object.new
        monkey.instance_eval { @limbs = [:arms, :legs] }
        def monkey.method_missing(method)
          @limbs.shift
        end
        monkey.method_info.method_owner!(:unknown_method)
        monkey.instance_eval('@limbs').should == [:legs]
      end

      it "raises an error if the object does not respond to the method" do
        lambda { ConcreteMethodOwnerDummy.new.method_info.method_owner!(:poof) }.should raise_error(NameError)
      end
    end
  end
end
