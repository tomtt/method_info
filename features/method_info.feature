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
boo
    """
