require 'method_info/ancestor_method_mapping'
require 'method_info/ancestor_method_structure'

module MethodInfo
  # Can produce different formats to represent an AncestorMethodStructure
  class Formatter
    def self.build(object, options)
      puts new(object, options).to_s
    end

    def to_s
      ss = @ancestor_method_structure.structure.map do |ancestor_with_methods|
        ancestor_with_methods_to_s(ancestor_with_methods)
      end
      ss.join("")
    end

    private

    def ancestor_with_methods_to_s(ancestor_with_methods)
      (ancestor, methods) = ancestor_with_methods
      s = "::: %s :::\n" % ancestor
      s += methods.join(", ") + "\n" unless methods.empty?
      s
    end

    def initialize(object, options)
      @object = object
      @ancestor_method_mapping = AncestorMethodMapping.new(object)
      @methods = @object.methods
      # select_methods
      # apply_match_filter_to_methods
      @ancestor_method_structure = AncestorMethodStructure.new(@ancestor_method_mapping, @methods)
      # @ancestor_filter = AncestorFilter.new(@ancestor_method_mapping.ancestors,
      #                                       :include => options[:ancestors_to_show],
      #                                       :exclude => options[:ancestors_to_exclude])
    end
  end
end
