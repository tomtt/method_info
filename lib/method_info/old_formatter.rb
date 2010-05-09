require 'method_info/ancestor_filter'
require 'method_info/ancestor_method_mapping'
require 'method_info/ancestor_method_structure'
require 'method_info/warn_for_old_ruby_version'

module MethodInfo
  # Can produce different formats to represent an AncestorMethodStructure
  class Formatter
    def self.build(object, options)
      if !options[:suppress_slowness_warning]
        WarnForOldRubyVersion.warn_if_method_owner_not_supported
      end

      Formatter.new(object, options)
    end

    def to_a
      @ancestor_method_structure.structure
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

    def initialize(object, options)
      @object = object
      @options = options
      @ancestor_method_mapping = AncestorMethodMapping.new(object)
      select_methods
      apply_match_filter_to_methods
      @ancestor_method_structure = AncestorMethodStructure.new(@ancestor_method_mapping, @methods)
      @ancestor_filter = AncestorFilter.new(@ancestor_method_mapping.ancestors,
                                            :include => options[:ancestors_to_show],
                                            :exclude => options[:ancestors_to_exclude])
    end

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
  end
end
