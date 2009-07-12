Feature: State machine
  In order to manage state
  As a developer
  I want to be able to set up a class as a state machine
  
  Scenario: I create a simple state machine
    Given I have declared a new Door class
    And I have added an initial state named closed
    And I have added a state called opened
    And I have added an event named open_it
    When I trigger the open event on an instance of Door
    Then the state of the instance of Door should be opened