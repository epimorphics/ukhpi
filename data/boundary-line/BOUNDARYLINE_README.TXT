   BOUNDARY-LINE™

  Notes on the Supply of Ordnance Survey Digital Data 
  ----------------------------------------------------
  Directory Structure of the media
  ---------------------------------
 
   This information is made up of 3 sections, containing examples:

   o  SECTION ONE - HIGH LEVEL STRUCTURE EXAMPLE
   o  SECTION TWO - AN EXAMPLE OF AN ORDER
   o  SECTION THREE - COMMENTS



   -------------------------------------------------------------------------------------------
   -------------------------------------------------------------------------------------------

   -----------
   SECTION ONE   
   -----------

   SECTION ONE - HIGH LEVEL STRUCTURE EXAMPLE


   The directory structure of the media is shown below:


                                   ROOT 
                                     |
             -----------------------------------------------
            |                   |                           |
           DOC           BOUNDARYLINE_README.txt           DATA

   -------------------------------------------------------------------------------------------
   -------------------------------------------------------------------------------------------

   -----------
   SECTION TWO   
   -----------

   2a - EXAMPLE - GB LAYERED and GB NESTED (SHAPE)
   2b - EXAMPLE - ORDER NOTES
   

   2a  EXAMPLE - GB LAYERED SHAPE
   ------------------------------

  GB_Layered_Shape
   |
   |--BOUNDARYLINE_README.TXT
   |
   |--DOC
   |   |--B-L_COMMUNITY_WARD_README.txt
   |   |--B-L_ER_CONST_README.txt
   |   |--Ceremonial_Counties.docx
   |   |--Counties-circa 1888-1889-Acts.docx
   |   |--DISCCARE.txt
   |   |--ukpga_20110001_en.pdf
   |   |--uksi_20140501_en.pdf
   |   
   |--DATA
       |   
       |
       |--GB
       |   |--DISTRICT_BOROUGH_UNITARY_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--EUROPEAN_REGION_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--HIGH_WATER_POLYLINE
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--PARISH_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--SCOTLAND_AND_WALES_CONST_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--SCOTLAND_AND_WALES_REGION_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--UNITARY_ELECTORAL_DIVISION_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--WESTMINSTER_CONST_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--COUNTY_ELECTORAL_DIVISION_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--COUNTY_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--GREATER_LONDON_CONST_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--DISTRICT_UNITARY_BOROUGH_WARD_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |
       |--Scotland
       |   |--scotland_and_wales_const_region
       |   |	     |... (.dbf .shp .shx .prj files)
       |   |--scotland_and_wales_region
       |   |         |... (.dbf .shp .shx .prj files)   
       |
       |--Supplementary_Ceremonial
       |   |--Boundary-line-ceremonial-counties
       |   |    |...(.dbf .shp .shx .prj files)
       |
       |--Supplementary_Historical
       |   |--Boundary-line-historic_counties_region
       |            |... (.dbf .shp .shx .prj files)
       |
       |--Wales
       |      |community_ward_region
       |      |      |... (.dbf .shp .shx .prj files)


    2a  EXAMPLE - GB NESTED SHAPE 
    ------------------------------

 GB_Nested_Shape
   |
   |--BOUNDARYLINE_README.TXT
   |
   |--DOC
   |   |--B-L_COMMUNITY_WARD_README.txt
   |   |--B-L_ER_CONST_README.txt
   |   |--Ceremonial_Counties.docx
   |   |--Counties-circa 1888-1889-Acts.docx
   |   |--DISCCARE.txt
   |   |--ukpga_20110001_en.pdf
   |   |--uksi_20140501_en.pdf
   |   
   |--DATA
       |  
       |
       |--GB
       |   |--DISTRICT_BOROUGH_UNITARY_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--EUROPEAN_REGION_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--HIGH_WATER_POLYLINE
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--PARISH_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--SCOTLAND_AND_WALES_CONST_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--SCOTLAND_AND_WALES_REGION_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--UNITARY_ELECTORAL_DIVISION_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--WESTMINSTER_CONST_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--COUNTY_ELECTORAL_DIVISION_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--COUNTY_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--GREATER_LONDON_CONST_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |   |--DISTRICT_UNITARY_BOROUGH_WARD_REGION
       |   |        |... (.dbf .shp .shx .prj files)
       |
       |--Scotland
       |   |--scotland_and_wales_const_region
       |   |	     |... (.dbf .shp .shx .prj files)
       |   |--scotland_and_wales_region
       |   |         |... (.dbf .shp .shx .prj files)   
       |
       |--Supplementary_Ceremonial
       |   |--Boundary-line-ceremonial-counties
       |   |    |...(.dbf .shp .shx .prj files)

       |--Supplementary_Historical
       |   |--Boundary-line-historic_counties_region
       |            |... (.dbf .shp .shx .prj files)
       |
       |--Wales
       |      |community_ward_region
       |      |      |... (.dbf .shp .shx .prj files)


   2b  EXAMPLE - ORDER NOTES
   ---------------------------

   This information will vary depending upon the chosen:

   o  AREA/COVERAGE (GB)
   o  TRANSFER FORMAT (for example: ESRI® Spatial data format
                                    MapInfo Table files (TAB format)
   o  NESTED/LAYERED

   -------------------------------------------------------------------------------------------
   -------------------------------------------------------------------------------------------

   -------------
   SECTION THREE   
   -------------

    COMMENTS
    --------

	Please send comments or suggestions relating to the Boundary-Line specification / product 
	or any other question to:

	Sales Information Helpdesk on 03456 05 05 05 or email:customerservices@os.uk

	Customer contact: https://www.ordnancesurvey.co.uk/contact/
 
	The latest User Guide and Technical Specification can be found on the Ordnance Survey Website,
	Located on the Boundary-Line technical product page.

	https://www.ordnancesurvey.co.uk/business-and-government/products/boundary-line.html

   --------------------------------------------------------
   README FILE CREATED BY ORDNANCE SURVEY, © May 2015
   --------------------------------------------------------
   V 1.3





