Feature: UKHPI Page
  As a data consumer
  I want to retrieve UK House Price Index data
  to use that data

  Scenario: app should be reachable from the home page
    Given I am a visitor
    When I open the url "/"
    Then I expect the page title contains "HM Land Registry Open Data"
    When I click the link with text "UK House Price Index"
    Then I expect the page title contains "UK House Price Index"

  Scenario: direct link navigation displays expected content
    Given I am a visitor
    When I open the url "app/ukhpi"
    Then I expect the page title contains "UK House Price Index"
    And I expect the element "body" contains text "UK House Price Index"
    And I expect the element "body" contains text "Use the search tool to find house price trends in the UK:"

  Scenario: should have the correct static content
    Given I am a visitor
    When I open the url "app/ukhpi"
    Then I expect the element "link[rel='stylesheet'][href*='application']" is on the page
    And I expect the element "img[alt='UKHPI Logo']" is on the page
    And I expect the element "img[alt='UKHPI Logo']" contains attribute "src" containing "ukhpi_logo"

  Scenario: should show figures for the current headline average price and monthly change
    Given I am a visitor
    When I open the url "app/ukhpi"
    Then I expect the element ".c-headline-figure__average-price" is on the page
    And I expect the element ".c-headline-figure__house-price-index" is on the page
    And I expect the element ".c-headline-figure__monthly-change" is on the page
    # TODO: Add regex pattern matching validation for dynamic content
    # Requires custom step definition supporting regex patterns:
    # - Average price should match: £[\d,]+ (e.g., "£250,000")
    # - House price index should match: [\d\.]+ (e.g., "123.45")
    # - Monthly change should match: (remained the same)|((fallen|risen) by [\d\.]+%)
    #   (e.g., "risen by 2.5%" or "remained the same")
    # WHY: cucumber-puppeteer's "contains text" step only supports exact substring matching, not regex

  Scenario: should be able to reach the application from the landing page
    Given I am a visitor
    When I open the url "app/ukhpi"
    Then I expect the page title contains "UK House Price Index"
    And I expect the element ".c-search-tool" is on the page
    When I click the link with text "search the UK house price index"
    Then I expect the page url contains "app/ukhpi/browse"
    And I expect the page title contains "House Price Statistics"
    And I expect the element "body" contains text "House Price Statistics"


  Scenario: should redirect from the old /explore URL to /browse
    Given I am a visitor
    When I open the url "app/ukhpi/explore"
    And I wait for 2 seconds
    Then I expect the page url contains "app/ukhpi/browse"

  Scenario: shows United Kingdom figures by default
    Given I am a visitor
    When I open the url "/app/ukhpi/browse"
    Then I expect the element ".c-options-selection__button" contains text "United Kingdom"

  Scenario: allows the user to select a different location
    Given I am a visitor
    When I open the url "/app/ukhpi/browse"
    And I click the button ".c-options-selection__button"
    And I set the element ".el-input input" value to "scotland"
    And I click the button "[aria-label='confirm']"
    And I wait for 1 second
    Then I expect the element ".c-options-selection__button" contains text "Scotland"
