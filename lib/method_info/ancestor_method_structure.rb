require 'method_info/ancestor_filter'

module MethodInfo
  class AncestorMethodStructure
    # :ancestors_to_show (default: []) (Overrules the hiding of any ancestors as specified
    #                    by the :ancestors_to_exclude option)
    # :ancestors_to_exclude (default: []) (If a class is excluded, all modules included
    #                       under it are excluded as well, an ancestor specified in
    #                       :ancestors_to_show will be shown regardless of the this value)
    # :method_missing (default: false)
    # :public_methods (default: true)
    # :protected_methods (default: false)
    # :private_methods (default: false)
    # :singleton_methods (default: true)
    # :include_name_of_excluded_ancestors (default: true)
    # :colors (default: false) TODO: configure colours
    def self.build(object, options)
      methods = []
      methods += object.methods if options[:public_methods]
      methods += object.protected_methods if options[:protected_methods]
      methods += object.private_methods if options[:private_methods]
      methods -= object.singleton_methods unless options[:singleton_methods]

      ancestor_method_structure = AncestorMethodStructure.new(object, options)

      methods.each do |method|
        ancestor_method_structure.add_method_to_ancestor(method)
      end
      ancestor_method_structure
    end

    def initialize(object, options)
      @object = object
      @options = options

      @ancestors = []
      if options[:singleton_methods]
        begin
          @ancestors << (class << object; self; end)
        rescue TypeError
        end
      end
      @ancestors += object.class.ancestors
      @ancestor_filter = AncestorFilter.new(@ancestors,
                                            :include => options[:ancestors_to_show],
                                            :exclude => options[:ancestors_to_exclude])

      @ancestor_methods = Hash.new
      @ancestors.each { |ancestor| @ancestor_methods[ancestor] = [] }
    end

    def add_method_to_ancestor(method)
      ancestor = AncestorMethodStructure.method_owner(@object, method)
      if @ancestors.include?(ancestor)
        @ancestor_methods[ancestor] << method
      end
    end

    def to_a
      ancestors_with_methods.map { |ancestor| [ancestor, @ancestor_methods[ancestor].sort] }
    end

    def to_s
      if @options[:enable_colors]
        require 'term/ansicolor'

        class_color = Term::ANSIColor.yellow
        module_color = Term::ANSIColor.red
        message_color = Term::ANSIColor.green
        reset_color = Term::ANSIColor.white
      else
        class_color = ""
        module_color = ""
        message_color = ""
        reset_color = ""
      end

      s = ancestors_with_methods.map do |ancestor|
        "%s::: %s :::\n%s%s\n" % [ancestor.is_a?(Class) ? class_color : module_color,
                                  ancestor.to_s,
                                  reset_color,
                                  @ancestor_methods[ancestor].sort.join(', ')]
      end.join('')
      if @options[:include_name_of_methodless_ancestors] && ! methodless_ancestors.empty?
        s += "#{message_color}Methodless:#{reset_color} " + methodless_ancestors.join(', ') + "\n"
      end
      if @options[:include_name_of_excluded_ancestors] && ! @ancestor_filter.excluded.empty?
        s += "#{message_color}Excluded:#{reset_color} " + @ancestor_filter.excluded.join(', ') + "\n"
      end
      s
    end

    private

    def methodless_ancestors
      @ancestor_filter.picked.select { |ancestor| @ancestor_methods[ancestor].empty? }
    end

    def ancestors_with_methods
      @ancestor_filter.picked.select { |ancestor| ! @ancestor_methods[ancestor].empty? }
    end

    # Returns the class or module where method is defined
    def self.method_owner(object, method)
      object.method(method).owner
    end

  end
end
