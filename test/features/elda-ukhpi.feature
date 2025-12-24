Feature: elda page

	As a data consumer

	I want to retrieve ukhpi data using the linked data api

	to use that data

# check the various formatters are working and returning correct mime type
	# Scenario Outline:
	# 	Given I am a visitor
	# 	When they retrieve the page "/data/ukhpi/region/fylde/month/2010-08"
	# 	And  they click on the "<format>" link
	# 	Then they should retrieve a "<mime_type>" file
	#     Examples:
	#     	| format | mime_type               |
	#     	| csv    | text/csv                |
	#     	| json   | application/json        |
	#     	| rdf    | application/rdf\\\\+xml |
	#     	| text   | text/plain              |
	#     	| ttl    | text/turtle             |
	#     	| xml    | application/xml         |

# check all properties are present
   @javascript
   Scenario:
        Given I am a visitor
        When I retrieve the page "/data/ukhpi/region/fylde/month/2013-08"
        Then I should retrieve a web page
        And it should have rules from stylesheet matching "/lda-assets/css/result.css$"
        And it should have content "house price index"
        And it should have content "house price index cash"
        And it should have content "house price index detached"
        And it should have content "house price index existing property"
        And it should have content "house price index first time buyer"
        And it should have content "house price index flat maisonette"
        And it should have content "house price index former owner occupier"
        And it should have content "house price index mortgage"
        And it should have content "house price index new build"
        And it should have content "house price index semi detached"
        And it should have content "house price index terraced"

        And it should have content "percentage annual change"
        And it should have content "percentage annual change cash"
        And it should have content "percentage annual change detached"
        And it should have content "percentage annual change existing property"
        And it should have content "percentage annual change first time buyer"
        And it should have content "percentage annual change flat maisonette"
        And it should have content "percentage annual change former owner occupier"
        And it should have content "percentage annual change mortgage"
        And it should have content "percentage annual change new build"
        And it should have content "percentage annual change semi detached"
        And it should have content "percentage annual change terraced"

        And it should have content "percentage change"
        And it should have content "percentage change cash"
        And it should have content "percentage change detached"
        And it should have content "percentage change existing property"
        And it should have content "percentage change first time buyer"
        And it should have content "percentage change flat maisonette"
        And it should have content "percentage change former owner occupier"
        And it should have content "percentage change mortgage"
        And it should have content "percentage change new build"
        And it should have content "percentage change semi detached"
        And it should have content "percentage change terraced"

        And it should have content "ref month"
        And it should have content "ref period start"
        And it should have content "ref period duration"

        And it should have content "average price"
        And it should have content "average price cash"
        And it should have content "average price detached"
        And it should have content "average price existing property"
        And it should have content "average price first time buyer"
        And it should have content "average price flat maisonette"
        And it should have content "average price former owner occupier"
        And it should have content "average price mortgage"
        And it should have content "average price new build"
        And it should have content "average price semi detached"
        And it should have content "average price terraced"

        And it should have content "house price index"
        And it should have content "house price index cash"
        And it should have content "house price index detached"
        And it should have content "house price index existing property"
        And it should have content "house price index first time buyer"
        And it should have content "house price index flat maisonette"
        And it should have content "house price index former owner occupier"
        And it should have content "house price index mortgage"
        And it should have content "house price index new build"
        And it should have content "house price index semi detached"
        And it should have content "house price index terraced"

        And it should have content "sales volume"
        And it should have content "type"
        And it should have content "UK house price indices"
        And it should have content "data set"
        And it should have content "dataset"
        And it should have content "ref region"

# check SA properties are present
   @javascript
   Scenario:
        Given I am a visitor
        When I retrieve the page "/data/ukhpi/region/north-west/month/2015-08"
        Then I should retrieve a web page
        And it should have rules from stylesheet matching "/lda-assets/css/result.css$"
        And it should have content "house price index SA"
        And it should have content "average price SA"
