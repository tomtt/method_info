module MethodInfo
  # Given an object, a subset of its methods and a subset of it's
  # ancestors, this class produces information about which of those
  # methods is owned by which of the object's ancestors.
  #
  # The basic information we need is a mapping from each method to the
  # first ancestor in the hierarchy that defines it. If no ancestor
  # defines the method it should map to nil.
  #
  # The external representation of this information is an array with
  # an element for each ancestor with the ancestor itself as the first
  # element and a list of methods that it defines as the second
  # element.
  class AncestorMethodStructure
    def initialize(object)
      @object = object
      @structure = nil
    end

    def structure
      build_structure
      @structure
    end

    private

    def build_structure
      @structure = Hash.new { |hash, key| hash[key] = [] }
      @object.methods.each do |method|
        @structure[@object.method(method).owner] << method.to_sym
      end
    end
  end
end
