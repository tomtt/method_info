@wip

Feature: Generating string representation of methods on an object
  In order to see only methods defined by ancestors unique to an object
  As a developer
  I want to filter out methods defined by ancestors common to all objects

  Scenario: method info for a symbol, hiding ancestors below Object
    Given I am using rvm "ruby-1.8.7-p249@bare"
    When I run ":bla.method_info(:hide_object)" in ruby with method_info required
    Then I should see:
    """
::: Symbol :::
===, id2name, inspect, to_i, to_int, to_proc, to_s, to_sym
Excluded: Object, MethodInfo::ObjectMethod, Kernel
    """
