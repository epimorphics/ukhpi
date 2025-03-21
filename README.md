# UK House Price Index (UKHPI) open data application

This is the repo for the application that presents UKHPI open data on behalf of
Land Registry (England and Wales), Registers of Scotland, Land and Property
Services (Northern Ireland) and the UK Office for National Statistics (ONS).

Please see the other repositories in the [HM Land Registry Open
Data](https://github.com/epimorphics/hmlr-linked-data/) project for more
details.

Development work was carried out by [Epimorphics
Ltd](http://www.epimorphics.com), funded by [HM Land
Registry](https://www.gov.uk/government/organisations/land-registry).

Code in this repository is open-source under the MIT license. The UKHPI data
itself is freely available under the terms of the [Open Government
License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

For more information about this project visit [the
wiki](https://github.com/epimorphics/ukhpi/wiki).

## Generating new location files from the UKHPI data

The location files are generated from the UKHPI data using the
`lib/tasks/location.rake` script. This script reads the UKHPI data from the
`SERVER` env var and generates the following updated location files:

- app/models/locations_table.rb
- app/javascript/data/locations_data.js

To generate the location files, run the following command:

```bash
SERVER=https://landregistry.data.gov.uk/app/ukhpi make locations
```

> [!NOTE] The `SERVER` env var should point to the appropriate SPARQL endpoint.
> Please verify the endpoint before running the command.

Further details on the generation of location files can be found in the
[wiki](https://github.com/epimorphics/ukhpi/wiki/Updating-geographies)
