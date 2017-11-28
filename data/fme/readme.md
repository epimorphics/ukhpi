# Generating the JSON outlines from ONS and OSNI data

We generate the outlines for countries, regions and local authorities using
FME. The source data is derived from
[ONS Boundaries data](http://geoportal.statistics.gov.uk/datasets?q=Latest_Boundaries&sort=name)
for England, Wales, and Scotland, and from
[OSNI boundaries data](http://osni-spatial-ni.opendata.arcgis.com/datasets?q=Boundaries&sort_by=relevance)
for Northern Ireland. After downloading the data, it is processed by one of
the two FME workspaces in this directory:

* [`GeoJSONfilecreation for ONS Geographies_v3.fmw`](file:GeoJSONfilecreation%for%ONS%Geographies_v3.fmw)
* [`GeoJSONfilecreation for OSNI Geographies_v2.fmw`](file:GeoJSONfilecreation%for%OSNI%Geographies_v2.fmw)

The FME workspaces were run with FME version `FME(R) 2017.1.1.0 (20170929 - Build 17650 - macosx)`
