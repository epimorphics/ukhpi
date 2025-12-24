# UKHPI application

Tags: UKHPI

The UK house price index displaying value of house sales

## Landing page

Tags: Landing, root

* The page loads with appropriate body content
* The page contains multiple links to the applications
* The page contains multiple links to external websites

## Change language

Tags: locale

Users can toggle between English and Welsh language

* Click Cymraeg link in top right
* Displayed body copy will change to Welsh language
* Navigation items will be displayed in Welsh language
* Clicking main navigation title will route user back to home page and language will default to English
* Click English link in top right
* All Displayed text will change to English language

## Header and primary navigation

Tags: navigation

* A custom header is visible which differs from the other applications
* The UKHPI logo is shown in the top left
* Clicking 'browse' will route users to the data display
* Clicking 'compare locations' will route users to the comparison table view
* Clicking 'SPARQL query' will route users to a SPARQL console view
* Clicking 'user guide' will route users to a user guide view
* Clicking 'about UKHPI' will route users to a page of descriptive information
* Clicking 'change history' will router users to a page of historic change information

## Location map view

Tags: query, filter

* Clicking the location edit button will open a modal dialogue with map view
* A User can zoom in and zoom out of the map with the '+' and '-' buttons
* A user can close the modal dialogue by clicking the cross icon

## Filter Location by keyword - select from list

Tags: query, filter

* Clicking the location edit button will open a modal dialogue with map view
* Typing 'Bi' will prompt a select menu of location options to appear
* A user can select an option from the select menu and click confirm button
* The modal dialogue will close and the location query parameter will be set
* Clicking the location edit button will open a modal dialogue with map view

## Filter Location by keyword - type location name

Tags: query, filter

* Clicking the location edit button will open a modal dialogue with map view
* A User can fully type 'London' and press enter
* The modal dialogue will close and the The location query parameter will be set

## Filter Location by map region

Tags: query, filter

* Clicking the location edit button will open a modal dialogue with map view
* A User can preview map segmentation of 'Countries'
* A User can preview map segmentation of 'Local authorities'
* A User can preview map segmentation of 'Regions of England'
* A User can preview map segmentation of 'Counties of England'
* Hover over a map segment will display a tooltip value
* Clicking a map segment will populate the search term field with tooltip value
* A User can click confirm button
* The modal dialogue will close and the location query parameter will be set

## Date range view - close window

Tags: query, filter, dates

* Clicking the date range edit button will open a modal dialogue with date range fields
* A User can click the close cross icon to close the modal dialogue
* The modal dialogue will close and the date range query parameter will not be set

## Date range view - cancel change

Tags: query, filter, dates

* Clicking the date range edit button will open a modal dialogue with date range fields
* A User can click 'cancel' button to close the modal dialogue
* The modal dialogue will close and the date range query parameter will not be set

## Date range view - select new value

Tags: query, filter, dates

* Clicking the date range edit button will open a modal dialogue with date range fields
* The date range defaults to starting a calendar year from the current previous month
* A User can empty the field input value by clicking the cross icon within field
* A User can select a year and month from the date picker control
* A User can click 'confirm' button
* The modal dialogue will close and the date range query parameter will be set

## invalid date range - empty field

Tags: query, filter, dates

* Clicking the date range edit button will open a modal dialogue with date range fields
* A User can empty the field input value by clicking the cross icon within field
* A User can click 'confirm' button
* The modal dialogue will close and the date range query parameter will inform user an empty field is an 'Invalid date'

## invalid date range - start date after end date

Tags: query, filter, dates

* Clicking the date range edit button will open a modal dialogue with date range fields
* Select 'Mar' and '2021' from the start field
* Select 'Jan' and '2021' from the end field
* A User can click 'confirm' button
* The modal dialogue will show a warning message 'The start date must be earlier than the end date'
