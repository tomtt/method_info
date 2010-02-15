module MethodInfo
  class AncestorMethodStructure
    # :ancestors_to_show (default: []) (Overrules the hiding of any ancestors as specified by the :ancestors_to_exclude option)
    # :ancestors_to_exclude (default: []) (If a class is excluded, all modules included under it are excluded as well, an ancestor specified in :ancestors_to_show will be shown regardless of the this value)
    # :method (default: nil) More detailed info about one method
    # :method_missing (default: false)
    # :public_methods (default: true)
    # :protected_methods (default: false)
    # :private_methods (default: false)
    # :singleton_methods (default: true)
    # :include_name_of_excluded_ancestors (default: true)
    # :format (default: nil)
    def self.build(object, options)
      methods = []
      methods += object.methods if options[:public_methods]
      methods += object.protected_methods if options[:protected_methods]
      methods += object.private_methods if options[:private_methods]
      methods -= object.singleton_methods unless options[:singleton_methods]
      ancestor_method_structure = AncestorMethodStructure.new(object, options)

      methods.each do |method|
        ancestor_method_structure.add_method_to_ancestor(method, method_owner(object, method))
      end
      ancestor_method_structure
    end

    def initialize(object, options)
      @options = options
      @ancestors = []
      @excluded_ancestors = []
      @ancestor_methods = {}
      if options[:singleton_methods]
        begin
          @ancestors << (class << object; self; end)
        rescue TypeError
        end
      end
      all_ancestors = object.class.ancestors
      last_class_was_excluded = false
      all_ancestors.each do |ancestor|
        if options[:ancestors_to_show].include?(ancestor)
          @ancestors << ancestor
          if ancestor.is_a?(Class)
            last_class_was_excluded = false
          end
        elsif options[:ancestors_to_exclude].include?(ancestor)
          if ancestor.is_a?(Class)
            last_class_was_excluded = true
            @excluded_ancestors << ancestor
          end
        else
          if ancestor.is_a?(Class)
            @ancestors << ancestor
            last_class_was_excluded = false
          else
            if last_class_was_excluded
              @excluded_ancestors << ancestor
            else
              @ancestors << ancestor
            end
          end
        end
      end
      @ancestors.each { |ancestor| @ancestor_methods[ancestor] = [] }
    end

    def add_method_to_ancestor(method, ancestor)
      if @ancestors.include?(ancestor)
        @ancestor_methods[ancestor] << method
      end
    end

    def to_a
      ancestors_with_methods.map { |ancestor| [ancestor, @ancestor_methods[ancestor].sort] }
    end

    def to_s
      s = ancestors_with_methods.map do |ancestor|
        "::: %s :::\n%s\n" % [ancestor.to_s, @ancestor_methods[ancestor].sort.join(', ')]
      end.join('')
      methodless_ancestors = @ancestors.select { |ancestor| @ancestor_methods[ancestor].empty? }
      if @options[:include_name_of_methodless_ancestors] && ! methodless_ancestors.empty?
        s += "Methodless: " + methodless_ancestors.join(', ') + "\n"
      end
      if @options[:include_name_of_excluded_ancestors] && ! @excluded_ancestors.empty?
        s += "Excluded: " + @excluded_ancestors.join(', ') + "\n"
      end
      s
    end

    private

    def ancestors_with_methods
      @ancestors.
        select { |ancestor| ! @ancestor_methods[ancestor].empty? }
    end

    # Returns the class or module where method is defined
    def self.method_owner(object, method)
      object.method(method).owner
    end

  end
end
