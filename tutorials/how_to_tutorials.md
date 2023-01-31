# How-To use the definitions.gms file...
Set of simple tutorials on how to change inputs in Euromod.

## Table of Contents
1. [Define sets, parameters, variables and equations](#definitions)
        1.1 [How to add a new set](##11-set)
        1.2 [How to define a new country](##12-country)
        1.3 [How to define a new parameter](##13-parameter)
        1.4 [How to define a new variable or equation](##14-var)
2. [Add power plants](#powerplants)
3. [Add parameters into reporting/reporting.gms](#reporting)

## Define sets, parameters, variables and equations(#definitions)

In order to define sets, parameters, variables, and equations, the user needs to go to the file **definitions.gms**.

1. How to add a new Set?(##11-set)

Sets are defined in the **Sets** section, as it is shown in the following code example:

```  
*-----------------------------------------------------------------------*
*                               Sets                                    *
*-----------------------------------------------------------------------*


Sets

****sets for reporting*************************************************
        item_rep                                        Items for reporting are mainly for creating the results.csv file
                             /"Error: CheckSum!","CO2 tonnes",Price, LostLoad,LostGeneration,Demand,Supply,PumpDemand,Curtailment,NetImport,Intercept, Slope, Biomass, Coal, Hydro, Gas, Oil, Other, Dam, PSClosed, PSOpen, PSP, RoR, Solar, WindOn, Nuclear, WindOff, Lignite, AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, GB, GR, HR, HU, IE, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, SK/
        
        item(item_rep)                                  Subset of items for reporting that are used in the reporting.gdx file
                             /"Error: CheckSum!","CO2 tonnes",LostLoad,LostGeneration,Demand,PumpDemand,Curtailment,NetImport,Biomass, Coal, Hydro, Gas, Oil, Other, Dam, PSClosed, PSOpen, PSP, RoR, Solar, WindOn, Nuclear, WindOff, Lignite/

****sets in model setup**************************************************
        all_t                                           all hours                   /1*8760/
        t(all_t)                                        hours used in the model     /%t_start% * %t_end%/
        tfirst(t)                                       first period
        tlast(t)                                        last period
        all_year                                        all years                   /2017, 2018, 2019, 2020/
        year                                            year used in the model      /%runyear%/
        
        n(item_rep)                                     nodes or countries                          /AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, GB, GR, HR, HU, IE, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, SK/
        eu(n)                                           countries that belong to EU                 /AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, GR, HR, HU, IE, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, SK/
        noneu(n)                                        countries that not belong to EU             /GB/
        l                                               lines

        p                                               power plants
        is_chp                                          identify power plants with chp
        
        tech(item_rep)                                  set of technologies                         /Biomass, Coal, Dam, Gas, Oil, Other, PSClosed, PSOpen, RoR, Solar, WindOn, Nuclear, WindOff, Lignite/
        dispatchtech(tech)                              subset of technologies that run hydro       /Biomass, Coal, Gas, Oil, Nuclear, Lignite/
        hydrotech(tech)                                 subset of technologies that run hydro       /Dam, PSClosed, PSOpen/
        restech(tech)                                   subset of RES technologies                  /Solar, WindOn, WindOff, RoR, Other/
        curtailtech(tech)                               subset of technologies that can curtail     /Solar, WindOn, WindOff/
        chp_tech(tech)                                  subset of technologies that have chp        /Biomass, Coal, Oil, Gas, Lignite/
        techcalib(item_rep)                             subset of technologies for calibration      /Biomass, Coal, Gas, Oil, Nuclear, Lignite, Hydro, Dam, PSClosed, PSOpen, PSP/


```  

1. How to define a new Gas and Battery technology in the sets (eg. Gas_CC and Battery)?

To add new technologies there are a couple of places that the user has to follow the following steps:
  a. Add Gas_CC and Baterry in the section sets for reporting in order to get the results in the gdx and csv files. This step is very important as many of the sets defined in the model are subsets of the item_rep set.

```  
****sets for reporting*************************************************
        item_rep                                        Items for reporting are mainly for creating the results.csv file
                             /"Error: CheckSum!","CO2 tonnes",Price, LostLoad,LostGeneration,Demand,
                             Supply,PumpDemand,Curtailment,NetImport,Intercept, Slope, Biomass, Coal, 
                             Hydro, Gas, Oil, Other, Dam, PSClosed, PSOpen, PSP, RoR, Solar, WindOn, 
                             Nuclear, WindOff, Lignite, Gas_CC, Battery, 
                             AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, 
                             GB, GR, HR, HU, IE, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, SK/
        
        item(item_rep)                                  Subset of items for reporting that are used in the reporting.gdx file
                             /"Error: CheckSum!","CO2 tonnes",LostLoad,LostGeneration,Demand,
                             PumpDemand,Curtailment,NetImport,Biomass, Coal, Hydro, Gas, Oil, 
                             Other, Dam, PSClosed, PSOpen, PSP, RoR, Solar, WindOn, Nuclear, 
                             WindOff, Lignite, Gas_CC, Battery/
```        
  b. Then, the user needs to add these two technologies in the respective technology set

``` 
        dispatchtech(tech)      subset of technologies that run hydro       /Biomass, Coal, Gas, Oil, Nuclear, Lignite, Gas_CC/
        restech(tech)           subset of RES technologies                  /Solar, WindOn, WindOff, RoR, Other, Battery/

``` 

2. How to define a new country (Turkey, defined as TR)?

To add a new country in the model definitions, the user needs to follow the same two steps described previously.
  a. Add TR in the section sets for reporting in order to get the results in the gdx and csv files.

```  
****sets for reporting*************************************************
        item_rep                                        Items for reporting are mainly for creating the results.csv file
                             /"Error: CheckSum!","CO2 tonnes",Price, LostLoad,LostGeneration,Demand,
                             Supply,PumpDemand,Curtailment,NetImport,Intercept, Slope, Biomass, Coal, 
                             Hydro, Gas, Oil, Other, Dam, PSClosed, PSOpen, PSP, RoR, Solar, WindOn, 
                             Nuclear, WindOff, Lignite, Gas_CC, Battery, 
                             AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, 
                             GB, GR, HR, HU, IE, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, SK,
                             TR/
```  

b. Then, the user needs to add TR in the respective country set (**n(item_rep)**). Additionally. as TR is a non-european country, we add TR to the **noneu(n)** set, otherwise the set we would have to change is the **eu(n)**.

```
        n(item_rep)        nodes or countries               /AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, GB, GR, 
                                                             HR, HU, IE, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, 
                                                             SK, TR/
        eu(n)              countries that belong to EU      /AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, GR, HR,
                                                             HU, IE, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, SK/
        noneu(n)           countries that not belong to EU  /GB, TR/
```
3. How to define a new parameter?

Model parameters are added in the parameters section. 
```
*-----------------------------------------------------------------------*
*                        Defining Parameters                            *
*-----------------------------------------------------------------------*

Parameters
        d(t,n)                                          load per node and t

        infeed(t,tech,n)                                res infeed per technology, node and t
        infeed_sum(t,n)                                 total res infeed per node and t

        q_max(t,p)                                      maximum capacity for power plants taking into account availabilities
        max_cap(t,p)                                    maximum capacity for power plants not taking into account availabilities
        availablity(n,tech,month)                       power plant availabilities per country tech and month
;
```

Here goes an example of how parameters are defined in the model. If the user needs to add a battery round efficiency, for example, it would do it as follows:

```
*-----------------------------------------------------------------------*
*                        Defining Parameters                            *
*-----------------------------------------------------------------------*

Parameters
        d(t,n)                                          load per node and t

        infeed(t,tech,n)                                res infeed per technology, node and t
        infeed_sum(t,n)                                 total res infeed per node and t

        q_max(t,p)                                      maximum capacity for power plants taking into account availabilities
        max_cap(t,p)                                    maximum capacity for power plants not taking into account availabilities
        availablity(n,tech,month)                       power plant availabilities per country tech and month
        
        battery_round_efficiency(n,restech)             battery round efficiency for each country and restech
        
;
```

4. How to define a new variable or equation?
Following the same logic as the previous examples, variables and equations are defined in the sections **Variables** and **Equations**. Following the Battery example, imagine the user would like to add a battery charge variable (BAT_CHARGE) and a capacity constraint. The changes can be seen in the following code:

```
###############################################################################
*@                           MODEL DEFINITIONS
*###############################################################################

*-----------------------------------------------------------------------*
*                              VARIABLES                                *
*-----------------------------------------------------------------------*

Positive Variables

        Q(t,p)                                          total generation by conventional power plants [MWh]
        BAT_CHARGE(t,p)                                 Battery charging variable [MWh]
        
        
;

*-----------------------------------------------------------------------*
*                              EQUATIONS                                *
*-----------------------------------------------------------------------*

Equations
*        Generation
         LIM_qmax(t,p)                                  Capacity restriction
         LIM_battery(t,p)                               Battery capacity constraint        
;

```

## Add power plants

To add power plants and their characteristics, the user needs to go to the file **input/capacity_blocks_2017.csv**, for example. Three more files similar to this one are included in the **input** folder.

Following the example of the battery, imagine the user wants to add a battery power plant of 500 MW and with a battery efficincy of 86% in the Great Britain (GB) for 2017. Going to the respective file, the user needs to add a row with the folowing information:

- scenario: Historic
- year: 2017
- climateyear: 2017
- country_sym: GB
- technology: Battery
- fuel: Lithium
- CHP: NO
- MW: 500
- efficiency: 0
- emission_factor: 0
- var_costs: 0
- bat_roundtrip: 0.86

## Add parameters into reporting/reporting.gms file

To add new parameters to the final report.gdx file, the user needs to follow the following steps. As an example, imagine we need a report parameter that aggregate all the hourly results per year, called report_yearly. 

  a. Define the new report parameter in the file **reporting/reporting_definitions_paramlist.gms/**:

```

************************************************************************


* Hourly
    %report_prefix%_nodal_price_hourly(t,n %scenariodimension%)  %reporting_command%
    
    %report_prefix%_hourly(t,n,item_rep %scenariodimension%)  %reporting_command%
    %report_prefix%_ntcflow(t,n,nn %scenariodimension%)  %reporting_command%
    %report_prefix%_storlevel_hourly(t,n %scenariodimension%)  %reporting_command%
    %report_prefix%_ntcflow_exp(t,n %scenariodimension%)  %reporting_command%
    %report_prefix%_ntcflow_imp(t,n %scenariodimension%)  %reporting_command%
    results(t,n,item_rep %scenariodimension%)  %reporting_command%
    
 * Yearly
    %report_prefix%_yearly(t,n,item_rep %scenariodimension%)  %reporting_command%

```

  a. Add the new parameter in the file **reporting/reporting_.gms/**:

```

*----------------------------------------------------------------------------------
* Yearly reporting
*----------------------------------------------------------------------------------

report_yearly(t,n,item_rep)            = SUM(t, report_hourly(t,n,item_rep));
