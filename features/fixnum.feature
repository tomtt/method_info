Feature: Generating string representation of methods on an object
  In order to find out what methods are defined on an object
  As a developer
  I want to see a list of methods grouped by the ancestor that defines them

  Scenario: Default string representation
    When I run "fixnum_method_info_example"
    Then I should see:
    """
Men at work
    """
