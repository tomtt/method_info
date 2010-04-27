module MethodInfo
  # Given an object, determine the owner for each of its methods. Also
  # keep note of the hierarchy of the object's ancestors
  class AncestorMethodMapping < Hash
    def initialize(object)
      @object = object
      find_owner_for_each_method
      build_ancestor_hierarchy
    end

    attr_reader :ancestors

    private

    def build_ancestor_hierarchy
      @ancestors = @object.class.ancestors
      @eigenclass = class << @object;self;end
      unless @ancestors.include?(@eigenclass)
        @ancestors = [@eigenclass] + @ancestors
      end
    end

    def find_owner_for_each_method
      @object.methods.each do |method|
        self[method.to_sym] = method_owner(method)
      end
    end

    # Returns the class or module where method is defined on @object
    def method_owner(method_symbol)
      # Under normal circumstances just calling @object.method(method_symbol) would work,
      # but this will go wrong if the object has redefined the method method.
      method = Object.instance_method(:method).bind(@object).call(method_symbol)

      method.owner
    end
  end
end
