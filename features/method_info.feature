@wip

Feature: Generating string representation of methods on an object
  In order to find out what methods are defined on an object
  As a developer
  I want to see a list of methods grouped by the ancestor that defines them

  Scenario: default method info for an integer
    Given I am using rvm "ruby-1.8.7-p249@bare"
    When I run "5.method_info" in ruby with method_info required
    Then I should see:
    """
::: Fixnum :::
%, &, *, **, +, -, -@, /, <, <<, <=, <=>, ==, >, >=, >>, [], ^, abs, div, divmod, even?, fdiv, id2name, modulo, odd?, power!, quo, rdiv, rpower, size, to_f, to_s, to_sym, zero?, |, ~
::: Integer :::
ceil, chr, denominator, downto, floor, gcd, gcdlcm, integer?, lcm, next, numerator, ord, pred, round, succ, times, to_i, to_int, to_r, truncate, upto
::: Precision :::
prec, prec_f, prec_i
::: Numeric :::
+@, coerce, eql?, nonzero?, remainder, singleton_method_added, step
::: Comparable :::
between?
::: Object :::
::: MethodInfo::ObjectMethod :::
method_info
::: Kernel :::
===, =~, __id__, __send__, class, clone, display, dup, enum_for, equal?, extend, freeze, frozen?, hash, id, inspect, instance_eval, instance_exec, instance_of?, instance_variable_defined?, instance_variable_get, instance_variable_set, instance_variables, is_a?, kind_of?, method, methods, nil?, object_id, private_methods, protected_methods, public_methods, respond_to?, send, singleton_methods, taint, tainted?, tap, to_a, to_enum, type, untaint
    """
