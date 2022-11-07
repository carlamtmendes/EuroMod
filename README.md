# EuroMod
Euromod a techno-economic model of the integrated European market with price granuality.

## Table of Contents
1. [About](#about)
2. [Quick Start](#quick-start)
3. [Documentation](#documentation)
4. [What's new](#whats-new)
5. [Citing EuroMod](#citing-euromod)
6. [License](#license)

## About
Euromod is a bottom-up model of the European interconnected power system, covering 27 countries: Austria, Belgium, Bulgaria, Czech Republic, Switzerland, Germany, Denmark, Estonia, Spain, Finland, France, Great Britain, Greece, Hungary, Ireland, Italy, Lithuania, Latvia, Netherlands, Norway, Poland, Portugal, Romania, Sweden, Slovenia, and Slovakia.

It minimizes total system costs with respect to dispatch, storage and interconnectors. For each hour of the year, demand and supply of electricity is matched and a clearing price is determined. Individual generation and storage technologies are explicitly modeled. Demand fluctuates exogenously and it is perfectly price-inelastic. It features 6 generation and 3 hydro storage technologies. Technologies such wind, solar, run-of-river and other renewables are exogenously included in the model as time-series.

The model is subject to a set of technical constraints related to demand and supply balance, combined heat and power, cycling of thermal plants, and operational constraints on hydro. Trading between bidding zones or countries is subject to net transfer capacity, and it takes place until arbitrage possibilities are exploited or capacity constraints become binding. Unit commitment and load flow are not modeled.

Markets are not assumed to be competitive by proposing two enhancements to the total system cost function: 

  1. to allow generators to bid or to sell electricity at prices which deviate from their SRMC, and 

  2. to apply a linear transformation on the resulting modelled prices so that they better reflect the volatility of prices seen in real power markets.

The resulting market-clearing price resembles the equilibrium price on European wholesale electricity markets.

Euromod is written in GAMS and solved by CPLEX on a desktop computer in about 10 minutes.

## Quick Start
Euromod can run on Windows, macOS and Linux. Before installing Euromod, you should proceed to the instalation of GAMS with a valid license. GAMS is available for download from the following website: https://www.gams.com

After downloading GAMS and Euromod, the model runs for the year 2017 by just running the file **run_model.gms**

The data files are prepared to run the years 2017, 2018, 2019, and 2020. To simulate one of those years, the user need to change the field **runyear** in the **run_model.gms** file (3rd code line).

```
* Define start and end hours

$if not set t_start                     $setglobal t_start                      1
$if not set t_end                       $setglobal t_end                        8760
$if not set runyear                     $setglobal runyear                      2017
$if not set solver                      $setglobal solver                       CPLEX
$if not set modelName                   $setglobal modelName                    Euromod
$if not set slope                       $setglobal slope                        0.35
$if not set scenario                    $setglobal scenario                     Historic
```
After the model is solved, the model data and results are uploaded into a GDX file and a summary of the main results are saved into a CSV file.

## Documentation
Euromod includes several modules that cover the input, optimization, and model's ouput.

### Inputs

- **\input**: folder containing the inputs by Euromod in CSV format
  - *availabilities.csv*: includes power plants availabilities per type.
  - *map_country.csv*: mapping countries to accronims used in the model.
  - *time.csv*: definition of time steps and its relation with year, months, weeks, days and quarters.
  - *capacities_block_2017.csv*: list of the power plants used in the model and their main characteristics.
  - *capacities_storage_hydro.csv*: reservoir storage capacity.
  - *capacities_pump.csv*: pumping capacity for pump-storage power plants.
  - *chp_demand.csv*: energy demand from chp.
  - *chp_profice.csv*: hourly chp profile.
  - *fuel_prices.csv*: gas, oil, coal, uran and co2 prices time-series.
  - *generation.csv*: historic hourly generation from ENTSO-E.
  - *inflows_weekly.csv*: water inflows per week.
  - *ntc_2017.csv*: net transfer capacities between bidding zones.
  - *load.csv*: time-series of hourly demand per bidding zone.
  - *hydro_ror.csv*: time-series of hourly run-of-river generation per bidding zone.
  - *solar.csv*: time-series of hourly solar PV generation per bidding zone.
  - *wind_on.csv*: time-series of hourly wind onshore generation per bidding zone.
  - *wind_off.csv*: time-series of hourly wind offshore generation per bidding zone.
  - *other_res.csv*: time-series of hourly other renewable generation per bidding zone.

- **\gdx**: folder containing all the uploaded data used by the model after calibration in the GDX format

### Optimization

- **run_model.gms**: file containing the main model definitions to run the simulations.

- **definitions.gms**: file where the main model definitions are defined, such as, sets, parameters, variables and equations.

- **read_data.gms**: file that uploads all data from the input folder and proceeds to the appropriate data transformations and calibrations to define all the parameters that will be used in the model. All the parameters created by this file are saved in a GDX file and stored intot the \gdx folder.

- **model.gms**: main model file where all the model constraints are defined.


### Output
- **\reporting**: folder containing the inputs by Euromod in CSV format
  - **reporting_definitions.gms**: file that contains the main definition items for reporting.
  - **reporting_definitions_paramlist.gms**: list of parameters used for reporting.
  - **reporting.gms**: main file used to define all the parameters used to sumarize all main results.

- **\results**: folder that stores all the GDX and CSV results files

Hourly results are saved into a CSV for the following categories
  - CO2 emissions
  - Wholesale Electricity Prices
  - Demand
  - Net-imports
  - Pump demand
  - Curtailment, Lost Load or Lost Generation
  - Power plant generation by technology
  - Cross-border flows

#### Examples of possible results for Great Britain in 2017:

##### Generation

![generation](https://github.ic.ac.uk/storage/user/1035/files/7945da02-36e8-4c87-aa51-bab31a64dbc4)


##### Electricity prices

![prices](https://github.ic.ac.uk/storage/user/1035/files/cd2195c9-61a2-4f1f-a355-ae4df09d734f)



## What's new

## Citing EuroMod

## License
