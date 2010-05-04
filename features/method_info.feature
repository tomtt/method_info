@wip

Feature: Generating string representation of methods on an object
  In order to find out what methods are defined on an object
  As a developer
  I want to see a list of methods grouped by the ancestor that defines them

  Background:
    Given an object "object" of class "CukeObject"
    And the ancestor hierarchy of object "object" is as follows:
    | CukeObject |
    | Object |
    | Kernel |
    And the object "object" has the following methods:
    | method | ancestor   |
    | foo    | CukeObject |
    | bar    | CukeObject |
    | baz    | Kernel     |

  Scenario: Default string representation
    When I call method info for object "object"
    Then the output should be:
    """
::: CukeObject :::
bar, foo
::: Object :::
::: Kernel :::
baz
    """
