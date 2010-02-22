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
      ancestor = method_owner(method)
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
    def method_owner(method_symbol)
      method = @object.method(method_symbol)
      method.owner
    rescue
      poor_mans_method_owner(method, method_symbol.to_s)
    end

    # Ruby 1.8.6 has no Method#owner method, this is a poor man's replacement. It has horrible
    # performance and may break for other ruby implementations than MRI.
    def poor_mans_method_owner(method, method_name)
      # A Method object has no :owner method, but we can infer it's owner from the result of it's
      # :to_s method. Examples:
      # 37.method(:rdiv).to_s => "#<Method: Fixnum#rdiv>"
      # 37.method(:ceil).to_s => "#<Method: Fixnum(Integer)#ceil>"
      # 37.method(:prec).to_s => "#<Method: Fixnum(Precision)#prec>"
      # obj.method(:singleton_method).to_s => "#<Method: #<Object:0x5673b8>.singleton_method>"
      if method.to_s =~ /^#<Method: (.*)[#.]#{Regexp.escape(method_name)}>$/
        owner_string = $1
        # Maybe it is a top level class and we're done
        if owner_string =~ /\w+\((\w+)\)/
          # Module or subclass (like 'Fixnum(Integer)')
          owner_string = $1
        elsif owner_string.include?("#<Object:")
          # probably the eigen class
          owner_string = "#<Class:#{owner_string}>"
        end
        @ancestors.select { |a| a.to_s == owner_string }.first
      end
    end
  end
end
