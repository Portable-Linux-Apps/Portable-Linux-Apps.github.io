# CRITERIA1D

 CRITERIA-1D is an agro-hydrological model that simulates one-dimensional water flow in variable saturation soils, crop development, root water extraction and irrigation water needs.
 
 Soil water flow can be simulated with two different approaches depending on the user's choice: a physically based numerical model or a layer-based conceptual model. Soil and crop parameters can be defined at different levels of detail. It requires daily agro-meteorological data as input:
  
 minimum and maximum air temperature, total precipitation and, if available, water table depth data to estimate capillary rise.
 
 CRITERIA-GEO is a GIS interface for managing geo-referenced model projects, it requires a crop map, a soil map and a meteorological grid. Each computation unit is defined as a different combination of crop, soil and meteo. The output is stored in a SQLite database and can be exported to csv, shapefile or raster data using the CriteriaOutput tool. Software is written in C++ using Qt libraries, so cross-platform building is possible (Windows, Linux, Mac OS).
 
 CRITERIA is operational at Arpae Emilia-Romagna and in the Climate Service for Irrigation Forecasting. It has been used in several international projects (Demeter, Ensembles, Vintage, Moses, Clara, Highlander, ADA) and it is reported in the International Soil Modeling Consortium.
 
 Criteria1D API is a project of VAIMEE to integrate the model into the most diverse applications, such as in ZENTRA cloud.

 SITE: https://github.com/ARPA-SIMC/CRITERIA1D

 | [Applications](https://portable-linux-apps.github.io/apps.html) | [Home](https://portable-linux-apps.github.io)
 | --- | --- |
