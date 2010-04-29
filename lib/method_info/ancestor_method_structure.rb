module MethodInfo
  # Gets initialized with an AncestorMethodMapping instance and uses the information it provides
  # to build a structure that can be used to easily generate every type of output.
  #
  # The mappings provides an ordered list of ancestors and a mapping
  # for each method to its owner, which is typically a member of the
  # ancestors list.
  #
  # The structure this is translated to looks like this:
  # [
  #   [Ancestor0, [:method0, :method1]],
  #   [Ancestor1, [:method2]],
  #   [nil, [:method_x]]
  # ]
  # Notes:
  # * The order of the elements in the array is the same as the order of the ancestors list
  # * The order of the methods is alphabetized by the string representation of the symbols
  # * Any method that does not have an owner or that has an owner that is not in the
  #   ancestors list will end up in the list with the nil ancestor
  class AncestorMethodStructure
    def initialize(ancestor_method_mapping, methods = nil)
      @ancestor_method_mapping = ancestor_method_mapping
      @methods = methods || @ancestor_method_mapping.keys
      build_structure
    end

    attr_reader :structure

    private

    def build_structure
      methods_by_owner = Hash.new { |hash, key| hash[key] = [] }
      ancestors = @ancestor_method_mapping.ancestors
      @methods.each do |method|
        ancestor = @ancestor_method_mapping[method]
        unless ancestors.include?(ancestor)
          ancestor = nil
        end
        methods_by_owner[ancestor] << method
      end
      if methods_by_owner.has_key?(nil)
        ancestors << nil
      end
      @structure = ancestors.map do |ancestor|
        [ancestor, AncestorMethodStructure.alphabetize(methods_by_owner[ancestor])]
      end
    end

    def self.alphabetize(list_of_symbols)
      list_of_symbols.map { |s| s.to_s }.sort.map { |s| s.to_sym }
    end
  end
end
