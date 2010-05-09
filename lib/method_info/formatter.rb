module MethodInfo
  # Can produce different formats to represent an AncestorMethodStructure
  class Formatter
    def self.build(object, options)
      sample = <<EOT
::: Fixnum :::
%, &, *, **, +, -, -@, /, <, <<, <=, <=>, ==, >, >=, >>, [], ^, abs, div, divmod, id2name, modulo, power!, quo, rdiv, rpower, size, to_f, to_s, to_sym, zero?, |, ~
::: Integer :::
ceil, chr, denominator, downto, floor, gcd, gcdlcm, integer?, lcm, next, numerator, round, succ, taguri, taguri=, times, to_i, to_int, to_r, to_yaml, truncate, upto
::: Precision :::
prec, prec_f, prec_i
::: Numeric :::
+@, coerce, eql?, nonzero?, remainder, singleton_method_added, step
::: Comparable :::
between?
::: Object :::
to_yaml_properties, to_yaml_style
::: MethodInfo::ObjectMethod :::
method_info
::: Kernel :::
===, =~, __id__, __send__, class, clone, display, dup, equal?, extend, freeze, frozen?, hash, id, inspect, instance_eval, instance_of?, instance_variable_defined?, instance_variable_get, instance_variable_set, instance_variables, is_a?, kind_of?, method, methods, nil?, object_id, private_methods, protected_methods, public_methods, respond_to?, send, singleton_methods, taint, tainted?, to_a, type, untaint
EOT

      puts sample
      # new(object, options)
    end

    def initialize(object, options)
      # @object = object
      # @options = options
      # @ancestor_method_mapping = AncestorMethodMapping.new(object)
      # select_methods
      # apply_match_filter_to_methods
      # @ancestor_method_structure = AncestorMethodStructure.new(@ancestor_method_mapping, @methods)
      # @ancestor_filter = AncestorFilter.new(@ancestor_method_mapping.ancestors,
      #                                       :include => options[:ancestors_to_show],
      #                                       :exclude => options[:ancestors_to_exclude])
    end
  end
end
