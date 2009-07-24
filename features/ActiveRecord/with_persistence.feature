Feature: State machine with persistence via ActiveRecord
  In order to persist state
  As a developer
  I want ActiveRecord to persist state

Background:
  Given I have declared a new ActiveRecord model Door
  And I have added an initial state named closed
  And I have added a state called opened
  And I have added an event named open_it

Scenario: I create an ActiveRecord based state machine (with persistence as integer)
  Given I have added an index based property I will use to manage persistence with ActiveRecord
  When I trigger the open event on an instance of Door
  Then the state of the instance of Door should be opened
  And the instance of Door should save
  And the state should persist when reloaded
  
Scenario: I load an ActiveRecord based state machine (with persistence as integer)
  Given I have added an index based property I will use to manage persistence with ActiveRecord
  And I trigger the open event on an instance of Door
  And I save the instance of door
  When I load the instance of Door
  Then the state should persist when loading from scratch

Scenario: I create an ActiveRecord based state machine (with persistence as string)
  Given I have added a string based property I will use to manage persistence with ActiveRecord
  When I trigger the open event on an instance of Door
  Then the state of the instance of Door should be opened
  And the instance of Door should save
  And the state should persist when reloaded

Scenario: I load an ActiveRecord based state machine (with persistence as string)
  Given I have added a string based property I will use to manage persistence with ActiveRecord
  And I trigger the open event on an instance of Door
  And I save the instance of door
  When I load the instance of Door
  Then the state should persist when loading from scratch
