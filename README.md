# EuroMod
EuroMod is a techno-economic electricity market model covering the integrated European market, with a focus on generating more realistic wholesale prices.

## Table of Contents
1. [About](#about)
2. [Quick Start](#quick-start)
3. [Documentation](#documentation)
4. [What's new](#whats-new)
5. [Citing EuroMod](#citing-euroMod)
6. [License](#license)

## About
EuroMod is a bottom-up model of the European interconnected power system, covering 27 countries: Austria, Belgium, Bulgaria, Czech Republic, Switzerland, Germany, Denmark, Estonia, Spain, Finland, France, Great Britain, Greece, Hungary, Ireland, Italy, Lithuania, Latvia, Netherlands, Norway, Poland, Portugal, Romania, Sweden, Slovenia, and Slovakia.

It minimizes total system costs with respect to dispatch, storage and interconnectors. For each hour of the year, demand and supply of electricity is matched and a clearing price is determined. Individual generation and storage technologies are explicitly modelled. It features 6 generation and 3 hydro storage technologies. Technologies such wind, solar, run-of-river and other renewables are exogenously included in the model as time-series. Demand fluctuates exogenously and it is perfectly price-inelastic.

The model is subject to a set of technical constraints related to demand and supply balance, combined heat and power, cycling of thermal plants, and operational constraints on hydro. Trading between bidding zones or countries is subject to net transfer capacity, and it takes place until arbitrage possibilities are exploited or capacity constraints become binding. Unit commitment of individual power stations and optimal load flow are not modelled.

Markets are not assumed to be competitive by proposing two enhancements to the total system cost function: 

  1. to allow generators to bid or to sell electricity at prices which deviate from their marginal cost, and 

  2. to apply a linear transformation on the resulting modelled prices so that they better reflect the volatility of prices seen in real power markets.

The resulting market-clearing price resembles the equilibrium price on European wholesale electricity markets.

EuroMod is written in GAMS and solved using CPLEX. The dispatch across 27 countries for one year of 8,760 hours can be solved on a desktop computer in about 10 minutes.

## Quick Start
EuroMod can run on Windows, macOS and Linux. Before installing EuroMod, you should install [GAMS](https://www.gams.com) with a valid license.

After downloading GAMS and EuroMod, the model runs for the year 2017 by just running the file **run_model.gms**

The data files are prepared to run the years 2017, 2018, 2019, and 2020. To simulate one of those years, the user need to change the field **runyear** in the **run_model.gms** file (3rd code line).

```
* Define start and end hours

$if not set t_start                     $setglobal t_start                      1
$if not set t_end                       $setglobal t_end                        8760
$if not set runyear                     $setglobal runyear                      2017
$if not set solver                      $setglobal solver                       CPLEX
$if not set modelName                   $setglobal modelName                    EuroMod
$if not set slope                       $setglobal slope                        0.47
$if not set scenario                    $setglobal scenario                     Historic
```
After the model is solved, the model data and results are uploaded into a GDX file and a summary of the main results are saved into a CSV file.

## Documentation
EuroMod includes several modules that cover the input, optimization, and model's ouput.

### Inputs

- **\input**: folder containing the inputs by EuroMod in CSV format
  - *availabilities.csv*: includes power plants availabilities per type.
  - *capacities_block_2017.csv*: list of the power plants used in the model and their main characteristics in 2017.
  - *capacities_block_2018.csv*: list of the power plants used in the model and their main characteristics in 2018.
  - *capacities_block_2019.csv*: list of the power plants used in the model and their main characteristics in 2019.
  - *capacities_block_2020.csv*: list of the power plants used in the model and their main characteristics in 2020.
  - *capacities_pump.csv*: pumping capacity for pump-storage power plants.
  - *capacities_storage_hydro.csv*: reservoir storage capacity.
  - *chp_demand.csv*: energy demand from chp.
  - *chp_profile.csv*: hourly chp profile.
  - *fuel_prices.csv*: gas, oil, coal, uran and co2 prices time-series.
  - *generation.csv*: historic hourly generation from ENTSO-E.
  - *hydro_ror.csv*: time-series of hourly run-of-river generation per country.
  - *inflows_weekly.csv*: water inflows per week.
  - *initial_storage_ratios.csv*: hydro storage intial ratios per week and country.
  - *initial_storage.csv*: initial hydro storage levels at beginning and end of the year.
  - *load.csv*: time-series of hourly demand per bidding zone.
  - *map_country.csv*: mapping countries to accronims used in the model.
  - *ntc_2017.csv*: net transfer capacities between countries in 2017.
  - *ntc_2018.csv*: net transfer capacities between countries in 2018.
  - *ntc_2019.csv*: net transfer capacities between countries in 2019.
  - *ntc_2020.csv*: net transfer capacities between countries in 2020.
  - *other_res.csv*: time-series of hourly other renewable generation per bidding zone.
  - *solar.csv*: time-series of hourly solar PV generation per bidding zone.
  - *wind_on.csv*: time-series of hourly wind onshore generation per bidding zone.
  - *wind_off.csv*: time-series of hourly wind offshore generation per bidding zone.
  - *time.csv*: definition of time steps and its relation with year, months, weeks, days and quarters.

- **\gdx**: folder containing all the uploaded data used by the model after calibration in the GDX format

### Optimization

- **run_model.gms**: file containing the main model definitions to run the simulations.

- **definitions.gms**: file where the main model definitions are defined, such as, sets, parameters, variables and equations.

- **read_data.gms**: file that uploads all data from the input folder and proceeds to the appropriate data transformations and calibrations to define all the parameters that will be used in the model. All the parameters created by this file are saved in a GDX file and stored intot the \gdx folder.

- **model.gms**: main model file where all the model constraints are defined.


### Output
- **\reporting**: folder containing the inputs by EuroMod in CSV format
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

![generation](https://user-images.githubusercontent.com/117671960/200371905-42e592c1-2193-4257-b45d-1afed4d05dee.png)

##### Electricity prices

![prices](https://user-images.githubusercontent.com/117671960/200371947-74b0d00c-016f-43bd-bd39-be13263271c8.png)

## What's new

## Credits and Contact

Please contact [Carla Mendes](c.tavares-mendes@imperial.ac.uk) if you have questions or comments about `EuroMod`.

#### Citing EuroMod
If you use `EuroMod` or code derived from it in academic work, please cite:

Carla Mendes, Iain Staffell, and Richard Green (2023). EuroMod: A Model of the European Power Market with Price Granularity.

#### License
BSD-3-Clause
