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
    # :include_names_of_excluded_ancestors (default: true)
    # :include_names_of_methodless_ancestors (default: true)
    # :enable_colors (default: false)
    # :class_color Set colour for a line printing out a class (only used when :enable_colors is true)
    # :module_color Set colour for a line printing out a module (only used when :enable_colors is true)
    # :message_color Set colour for a line with a message (only used when :enable_colors is true)
    # :methods_color Set colour for a line with methods (only used when :enable_colors is true)
    # :punctuation_color Set colour for punctuation (only used when :enable_colors is true)
    # :suppress_slowness_warning Does not print out the warning about slowness on older ruby versions (default: false)
    # :match Shows only those methods that match this option. It's value can be either a string or a regexp (default: nil)
    def self.build(object, options)
      # print warning message if a Method does not support the :owner method
      if !options[:suppress_slowness_warning] && ! Method.instance_methods.include?("owner")
        STDERR.puts "You are using a Ruby version (#{VERSION}) that does not support the owner method of a Method - this may take a while. It will be faster for >=1.8.7."
      end

      ancestor_method_structure = AncestorMethodStructure.new(object, options)
      ancestor_method_structure.add_selected_methods_to_structure
      ancestor_method_structure
    end

    def initialize(object, options)
      @object = object
      @options = options

      @ancestors = []
      @unattributed_methods = []

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
      unless ancestor
        @unattributed_methods << method
      end
    end

    def to_a
      ancestors_with_methods.map { |ancestor| [ancestor, @ancestor_methods[ancestor].sort] }
    end

    def to_s
      if @options[:enable_colors]
        require 'term/ansicolor'

        class_color = @options[:color_class] || Term::ANSIColor.yellow
        module_color = @options[:color_module] || Term::ANSIColor.red
        message_color = @options[:color_message] || Term::ANSIColor.green
        methods_color = @options[:color_methods] || Term::ANSIColor.reset
        punctuation_color = @options[:color_punctuation] || Term::ANSIColor.reset
        reset_color = Term::ANSIColor.reset
      else
        class_color = ""
        module_color = ""
        message_color = ""
        methods_color = ""
        reset_color = ""
        punctuation_color = ""
      end

      ancestors_to_show = @ancestor_filter.picked
      unless @options[:include_names_of_methodless_ancestors]
        ancestors_to_show = ancestors_with_methods
      end

      s = ancestors_to_show.map do |ancestor|
        result = "%s::: %s :::\n" % [ancestor.is_a?(Class) ? class_color : module_color,
                                     ancestor.to_s]
        unless @ancestor_methods[ancestor].empty?
          result += "%s%s\n" % [methods_color,
                                @ancestor_methods[ancestor].sort.join("#{punctuation_color}, #{methods_color}")]
        end
        result
      end.join('')
      # if @options[:include_names_of_methodless_ancestors] && ! methodless_ancestors.empty?
      #   s += "#{message_color}Methodless:#{reset_color} " + methodless_ancestors.join(', ') + "\n"
      # end
      if @options[:include_names_of_excluded_ancestors] && ! @ancestor_filter.excluded.empty?
        s += "#{message_color}Excluded:#{reset_color} " + @ancestor_filter.excluded.join(', ') + "\n"
      end
      if @options[:include_names_of_unattributed_methods] && ! @unattributed_methods.empty?
        s += "#{message_color}Unattributed methods:#{reset_color} " + @unattributed_methods.join(', ') + "\n"
      end
      s += reset_color
      s
    end

    def add_selected_methods_to_structure
      select_methods
      apply_match_filter_to_methods
      @methods.each do |method|
        add_method_to_ancestor(method)
      end
    end

    private

    def select_methods
      @methods = []
      @methods += @object.methods if @options[:public_methods]
      @methods += @object.protected_methods if @options[:protected_methods]
      @methods += @object.private_methods if @options[:private_methods]
      @methods -= @object.singleton_methods unless @options[:singleton_methods]
    end

    def apply_match_filter_to_methods
      if(match = @options[:match])
        unless match.is_a?(Regexp)
          match = Regexp.new(match)
        end
        @methods = @methods.select { |m| m =~ match }
      end
    end

    def methodless_ancestors
      @ancestor_filter.picked.select { |ancestor| @ancestor_methods[ancestor].empty? }
    end

    def ancestors_with_methods
      @ancestor_filter.picked.select { |ancestor| ! @ancestor_methods[ancestor].empty? }
    end

    # Returns the class or module where method is defined
    def method_owner(method_symbol)
      # Under normal circumstances just calling @object.method(method_symbol) would work,
      # but this will go wrong if the object has redefined the method method.
      method = Object.instance_method(:method).bind(@object).call(method_symbol)

      method.owner
    rescue NameError
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
      # For a nested module: "#<Method: Module1::ClassName(Module1::Module2::Module3)#method>"

      build_ancestor_regexp_map
      @ancestors.each do |ancestor|
        return ancestor if method.to_s =~ @ancestor_regexp_map[ancestor]
      end
      nil
    end

    def build_ancestor_regexp_map
      unless @ancestor_regexp_map
        @ancestor_regexp_map = Hash.new
        @ancestors.each do |ancestor|
          ancestor_name = ancestor.to_s
          if ancestor_name =~ /^#<Class:(.*)>$/
            ancestor_name = $1
          end
          @ancestor_regexp_map[ancestor] = /#{Regexp.escape(ancestor_name)}[)#.]/
        end
      end
    end
  end
end
