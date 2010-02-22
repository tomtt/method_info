module MethodInfo

  # Utility class to filter a list of ancestors, taking the class/module hierarchy into account
  class AncestorFilter
    # A list of the ancestors that were picked by the filter
    attr_reader :picked

    # Creates an AncestorFilter and performs a filtering based on the options passed.
    # ==== Parameters
    #
    # * <tt>:include</tt> - An ancestor that is in this list and the original ancestor list will always be included, regardless of the value of :exclude.
    # * <tt>:exclude</tt> - A list of ancestors that are to be excluded from the original list. If a class is excluded, all modules included under it are excluded as well.
    def initialize(ancestors, options = {})
      @ancestors = ancestors
      filter(options)
    end

    # Perform another filter operation on the same list of ancestors. See initialize for supported
    # options.
    def filter(options = {})
      @options = options
      @exclude = @options[:exclude] || []
      @include = @options[:include] || []
      @picked =
        @ancestors -
        (@exclude - included_ancestors) -
        (modules_under_excluded_classes - included_ancestors)
    end

    # A list of the ancestors that were excluded by the filter
    def excluded
      @ancestors - @picked
    end

    private

    def included_ancestors
      @ancestors & @include
    end

    def modules_under_excluded_classes
      group_ancestors_by_class
      @ancestors.select { |ancestor| ancestor.is_a?(Class) && @exclude.include?(ancestor) }.
        map { |klass| @class_module_map[klass] }.flatten
    end

    def group_ancestors_by_class
      @class_module_map = Hash.new
      @last_class = nil
      @class_module_map[nil] = []
      @ancestors.each do |ancestor|
        if ancestor.is_a?(Class)
          @class_module_map[ancestor] = []
          @last_class = ancestor
        else
          @class_module_map[@last_class] << ancestor
        end
      end
    end
  end
end
