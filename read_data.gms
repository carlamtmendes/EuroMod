*###############################################################################
*@                          UPLOAD DATA
*###############################################################################

*-------------------------------------------------------------------------------
*@@                       UPLOAD DATA
*-------------------------------------------------------------------------------

$onEchoV > symRead.gms
%1 %2 %3 '%4';
$set val
$if not x%7==x $set val value=%7
$call.checkErrorLevel "csv2gdx input/%5 id=tmp index=%6 %val% useHeader=y output=gdx/%2"
$gdxIn gdx/%2
$load %2=tmp
$offEcho

$onUNDF
$batInclude symRead Set map_time                  (time<,year,month<,quarter,day<,hour<,week<,t)           'time map'                  time.csv                                             1..8
$batInclude symRead Set map_plants                (p<,scen<,year,n,tech,fuel<,is_chp<)                     'plants map'                capacities_block_%runyear%.csv                       14,2,3,5..8
$batInclude symRead Set map_lines                 (scen,year,l<,n,nn)                                      'lines map'                 ntc_%runyear%.csv                                    1,2,4..6

$batInclude symRead Parameter load                (time,n)                                                 'load'                      load.csv                                             1            2..lastCol
$batInclude symRead Parameter solar               (time,n)                                                 'solar infeed'              solar.csv                                            1            2..lastCol
$batInclude symRead Parameter windon              (time,n)                                                 'wind onshore infeed'       wind_on.csv                                          1            2..lastCol
$batInclude symRead Parameter windoff             (time,n)                                                 'wind offshore infeed'      wind_off.csv                                         1            2..lastCol
$batInclude symRead Parameter otherRES            (time,n)                                                 'other res infeed'          other_res.csv                                        1            2..lastCol
$batInclude symRead Parameter ror                 (time,n)                                                 'RoR infeed'                hydro_ror.csv                                        1            2..lastCol
$batInclude symRead Parameter chp_demand          (n,year)                                                 'chp ENTSOE demand'         chp_demand.csv                                       2            3..lastCol
$batInclude symRead Parameter water_inflow        (n,week,*)                                               'water inflows'             inflows_weekly.csv                                   2..3         4..lastCol
$batInclude symRead Parameter fuel_price_up       (time,year,*)                                            'fuel prices'               fuel_prices.csv                                      2,3          4..lastCol
$batInclude symRead Parameter initial_storage     (n,year,week,*)                                          'initial storage levels'    initial_storage.csv                                  1..3         4..lastCol
$batInclude symRead Parameter initial_stor_ratio  (n,week,*)                                               'initial storage ratios'    initial_storage_ratios.csv                           1..2         3..lastCol

$batInclude symRead Parameter ntc                 (scen,year,l,n,nn)                                       'ntc'                       ntc_%runyear%.csv                                    1,2,4..6     7..lastCol
$batInclude symRead Parameter plant_con           (p,scen,year,n,tech,fuel,is_chp,*)                       'plant upload data'         capacities_block_%runyear%.csv                       14,2,3,5..8  9..13
$batInclude symRead Parameter chp_profile         (t)                                                      'chp hourly profile'        chp_profile.csv                                      2            3..lastCol
$batInclude symRead Parameter avail               (n,tech,month)                                           'availabilities'            availabilities.csv                                   1,2          3..lastCol
$batInclude symRead Parameter cap_stor            (n,tech)                                                 'storage hydro capacity'    capacities_storage_hydro.csv                         5,6          7
$batInclude symRead Parameter cap_pump            (n,tech)                                                 'storage hydro capacity'    capacities_pump.csv                                  5,6          7

$batInclude symRead Parameter hist_gen            (scen,year,n,item_rep)                                   'historic generation'       generation.csv                                       2,3,5..6     7

$offUNDF

*-------------------------------------------------------------------------------
*@@                       MAPPING SETS
*-------------------------------------------------------------------------------
map_plants(p,scen,year,n,tech,fuel,is_chp) = no;
map_plants(p,scen,year,n,tech,fuel,is_chp)$(plant_con(p,scen,year,n,tech,fuel,is_chp,'MW') gt 0) = yes;

option
         map_np < map_plants
         map_ptech < map_plants
         map_pfuel < map_plants
         map_techfuel < map_plants
         map_tyear < map_time
         map_tmonth < map_time
         map_tweek < map_time
         map_ttime < map_time
         map_tquarter < map_time
         map_l_n_nn < map_lines
;


map_pchp(p) = SUM((scen,year,n,tech,fuel), map_plants(p,scen,year,n,tech,fuel,'YES'));

*-------------------------------------------------------------------------------
*@@                       INITIALIZE AND COUNT HOURS
*-------------------------------------------------------------------------------


tfirst(t) = no;
tfirst(t)$(ord(t) = 1) = yes;

tlast(t) = no;
tlast(t)$(ord(t) eq card(t)) = yes;

Parameter
    counttmonth(month)      count t in the month
    counttquarter(quarter)  count t in the quarter
    counttweek(week)        count t in the week

;

counttmonth(month) = SUM(t$map_tmonth(t,month),1);
counttquarter(quarter) = SUM(t$map_tquarter(t,quarter),1);
counttweek(week) = SUM(t$map_tweek(t,week),1);

*###############################################################################
*@                          UPLOAD DATA
*###############################################################################

*-------------------------------------------------------------------------------
*@@                       DEMAND
*-------------------------------------------------------------------------------
d(t,n)                  =   SUM(map_ttime(t,time), load(time,n));

*-------------------------------------------------------------------------------
*@@                       RES INFEED
*-------------------------------------------------------------------------------

infeed(t,'Solar',n)     =   SUM(map_ttime(t,time), solar(time,n));
infeed(t,'WindOn',n)    =   SUM(map_ttime(t,time), windon(time,n));
infeed(t,'WindOff',n)   =   SUM(map_ttime(t,time), windoff(time,n));
infeed(t,'RoR',n)       =   SUM(map_ttime(t,time), ror(time,n));
infeed(t,'Other',n)     =   SUM(map_ttime(t,time), otherRES(time,n))
                           + ((hist_gen("%scenario%","%runyear%",n,"Other") * 1000 ) -  SUM(time, otherRES(time,n))) / 8760;

* replace neg values values from infeed with 0

infeed(t,'Solar',n)$(infeed(t,'Solar',n) < 0) = 0;
infeed(t,'WindOn',n)$(infeed(t,'WindOn',n) < 0) = 0;
infeed(t,'WindOff',n)$(infeed(t,'WindOff',n) < 0) = 0;
infeed(t,'RoR',n)$(infeed(t,'RoR',n) < 0) = 0;
infeed(t,'Other',n)$(infeed(t,'Other',n) < 0) = 0;


infeed_sum(t,n) =  SUM(restech,infeed(t,restech,n));


*-------------------------------------------------------------------------------
*@@                       HYDRO INFLOWS
*-------------------------------------------------------------------------------

inflow(t,n,hydrotech) = 0;

** water inflows are based on 2017 as this is the last year we have data.
** All years have the same water inflows
inflow(t,n,"Dam") = SUM(week, map_tweek(t,week) * (water_inflow(n,week,"dam_inflow_MWh")/counttweek(week)));
inflow(t,n,"PSOpen") = SUM(week, map_tweek(t,week) * (water_inflow(n,week,"pump_inflow_MWh")/counttweek(week)));


*-------------------------------------------------------------------------------
*@@                       FUEL PRICES
*-------------------------------------------------------------------------------

fuel_price_eu(t,'Gas',eu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'EU_GasPrice'));
fuel_price_gb(t,'Gas',noneu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'GB_GasPrice'));

fuel_price_eu(t,'Coal',eu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'EU_CoalPrice'));
fuel_price_gb(t,'Coal',noneu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'GB_CoalPrice'));

fuel_price_eu(t,'Oil',eu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'EU_OilPrice'));
fuel_price_gb(t,'Oil',noneu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'GB_OilPrice'));

fuel_price_eu(t,'Uran',eu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'NuclearPrice'));
fuel_price_gb(t,'Uran',noneu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'NuclearPrice'));

fuel_price_eu(t,'Lignite',eu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'LignitePrice'));
fuel_price_gb(t,'Lignite',noneu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'LignitePrice'));

fuel_price_eu(t,'Biomass',eu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'BiomassPrice'));
fuel_price_gb(t,'Biomass',noneu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'BiomassPrice'));

co2_price_eu(t,eu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'EU_CO2Price'));
co2_price_gb(t,noneu) = SUM((year,map_ttime(t,time)), fuel_price_up(time,year,'GB_CO2Price'));

***** CO2 INTENSITY

co2_intensity('Coal') = 0.951867;
co2_intensity('Gas') = 0.378574;
co2_intensity('Lignite') = 0.980184;
co2_intensity('Oil') = 0.823422;

*-------------------------------------------------------------------------------
*@@                       NTC
*-------------------------------------------------------------------------------

Parameter
ntc_loss(nn,n)    transmission losses
;


ntc_line(n,nn) = YES$SUM(map_l_n_nn(l,n,nn),1);

cap_ntc(t,n,nn) =   SUM(l, ntc("%scenario%","%runyear%",l,n,nn));

ntc_loss(nn,n)$ntc_line(n,nn) = 0.001;

*-------------------------------------------------------------------------------
*@@                       AVAILABILITIES
*-------------------------------------------------------------------------------
* Availabilities per country (helps calibration)

availablity(n,tech,month) = 1;

availablity(n,tech,month) = avail(n,tech,month);
availablity(n,tech,month)$(availablity(n,tech,month) eq 0) = availablity('CH',tech,month);

* Availabilities for Hydro
availablity(n,'PSOpen',month) = 1;
availablity(n,'PSClosed',month) = 1;
availablity(n,'Dam',month) = 1;

availablity(n,tech,month)$(availablity(n,tech,month) gt 1) = 1;



*-------------------------------------------------------------------------------
*@@                       CALIBRATION
*-------------------------------------------------------------------------------

$IF NOT %module_calibration%=="yes" $goto end_calibration
availablity('FI','Nuclear',month) = 1;
availablity('GB','Nuclear',month) = availablity('GB','Nuclear',month) * 0.92;
availablity('BG','Nuclear',month) = availablity('BG','Nuclear',month) * 1.30;
availablity('RO','Nuclear',month) = availablity('BG','Nuclear',month) * 1.35;
availablity('SK','Nuclear',month) = availablity('SK','Nuclear',month) * 1.08;
availablity('CH','Nuclear',month) = availablity('CH','Nuclear',month) * 1.19;

inflow(t,"IT",'Dam') = inflow(t,"IT",'Dam') * 0.5;

fuel_price_eu(t,'Lignite','DE') = fuel_price_eu(t,'Lignite','DE') * 0.75;

cap_ntc(t,'DE','AT') = 2500;
cap_ntc(t,'AT','DE') = 2500;
cap_ntc(t,'DE','NL') = 2500;
cap_ntc(t,'NL','DE') = 2500;
cap_ntc(t,'DE','FR') = 1800;
cap_ntc(t,'FR','DE') = 2300;

$label end_calibration


** CORRECT HYDRO IN CH
Parameter
hydro_ch_tot(tech,n)
hydro_ch_share(t,tech,n)
hydro_ch_bfedata(year)
;

$IF %runyear%=='2017'   hydro_ch_bfedata('2017') =   36327000;
$IF %runyear%=='2018'   hydro_ch_bfedata('2018') =   36449000;
$IF %runyear%=='2019'   hydro_ch_bfedata('2019') =   36567000;
$IF %runyear%=='2020'   hydro_ch_bfedata('2020') =   36741000;

hydro_ch_tot('RoR','CH') = SUM(t,infeed(t,'RoR','CH'));
hydro_ch_share(t,'RoR','CH')$hydro_ch_tot('RoR','CH') = infeed(t,'RoR','CH')/hydro_ch_tot('RoR','CH');
infeed(t,'RoR','CH') = hydro_ch_bfedata('%runyear%') * 0.487 * hydro_ch_share(t,'RoR','CH');


*-------------------------------------------------------------------------------
*@@                       CAPACITIES
*-------------------------------------------------------------------------------
** RoR is a infeed, so there is no capacity
plant_con(p,"%scenario%","%runyear%",n,'RoR',fuel,is_chp,'MW') = 0;

loop(tech,
       q_max(t,p)$SUM((n,fuel,is_chp),
                     plant_con(p,"%scenario%","%runyear%",n,tech,fuel,is_chp,'MW'))
       = SUM((map_tmonth(t,month),map_np(n,p)),availablity(n,tech,month))
         * SUM((n,fuel,is_chp),
                     plant_con(p,"%scenario%","%runyear%",n,tech,fuel,is_chp,'MW'))
);


loop(tech,
       max_cap(t,p)$SUM((n,fuel,is_chp),
                     plant_con(p,"%scenario%","%runyear%",n,tech,fuel,is_chp,'MW'))
       = SUM((n,fuel,is_chp),
                     plant_con(p,"%scenario%","%runyear%",n,tech,fuel,is_chp,'MW'))
);

q_max(t,p)$(q_max(t,p) gt max_cap(t,p))    =   max_cap(t,p);



*-------------------------------------------------------------------------------
*@@                       CHP
*-------------------------------------------------------------------------------

** NOTE: Historic data from Eurostat.

chp_energy_year(n,year) = chp_demand(n,year);

* calculate total capacity per country and technology that can provide CHP
q_max_tot(p,n)  =   SUM((tech,fuel,is_chp)$map_pchp(p), plant_con(p,"%scenario%","%runyear%",n,tech,fuel,is_chp,'MW'));

total_capacity_country(n) = SUM((p,tech,fuel,is_chp)$map_pchp(p), plant_con(p,"%scenario%","%runyear%",n,tech,fuel,is_chp,'MW'));

p_share_in_q_max_tot(p,n)$total_capacity_country(n)   =  q_max_tot(p,n) / total_capacity_country(n);

chp_demand_year(p,n) = SUM(year,chp_energy_year(n,year) * p_share_in_q_max_tot(p,n));

chp(t,p) = Sum(n, chp_profile(t) * chp_demand_year(p,n));


* ensure hourly feasibility. In infeasible hours set chp demand to 50% for available capacity
chp_infes(t,p)$(chp(t,p) > q_max(t,p)) = chp(t,p) - q_max(t,p);
chp(t,p)$(chp_infes(t,p) > 0) = q_max(t,p)*0.5;


* for some countries, CHP demand is extremly high (above 50%)
* we restrict chp demand to be maximum 30 percent of total demand

chp_dem_country(t,n,p) = SUM(map_np(n,p), chp(t,p));

adjust_chp(n) = SUM((t,p), chp_dem_country(t,n,p))/SUM(t, d(t,n));

adjust_chp(n)$(adjust_chp(n) > 0.3) = 0.3/adjust_chp(n);
adjust_chp(n)$(adjust_chp(n) <= 0.3) = 1;

chp(t,p) = SUM(n, chp_dem_country(t,n,p) * adjust_chp(n));

*-------------------------------------------------------------------------------
*@@                      COST FUNCTION
*-------------------------------------------------------------------------------

* with EU fuel prices
loop(fuel,
      mc(t,p)$SUM((eu,tech,is_chp),
                            plant_con(p,"%scenario%","%runyear%",eu,tech,fuel,is_chp,'efficiency'))


                         = SUM(map_np(eu,p), fuel_price_eu(t,fuel,eu))
      / SUM((eu,tech,is_chp),
                            plant_con(p,"%scenario%","%runyear%",eu,tech,fuel,is_chp,'efficiency'))
      + SUM(map_np(eu,p), co2_price_eu(t,eu))
      * SUM((eu,tech,is_chp),
                            plant_con(p,"%scenario%","%runyear%",eu,tech,fuel,is_chp,'emission_factor'))


      + SUM((eu,tech,is_chp),
                            plant_con(p,"%scenario%","%runyear%",eu,tech,fuel,is_chp,'var_costs'))
);

* with GB fuel prices
loop(fuel,
      mc(t,p)$SUM((noneu,tech,is_chp),
                            plant_con(p,"%scenario%","%runyear%",noneu,tech,fuel,is_chp,'efficiency'))


                         = SUM(map_np(noneu,p), fuel_price_gb(t,fuel,noneu))
      / SUM((noneu,tech,is_chp),
                            plant_con(p,"%scenario%","%runyear%",noneu,tech,fuel,is_chp,'efficiency'))
      + SUM(map_np(noneu,p), co2_price_gb(t,noneu))
      * SUM((noneu,tech,is_chp),
                            plant_con(p,"%scenario%","%runyear%",noneu,tech,fuel,is_chp,'emission_factor'))


      + SUM((noneu,tech,is_chp),
                            plant_con(p,"%scenario%","%runyear%",noneu,tech,fuel,is_chp,'var_costs'))
);


*-------------------------------------------------------------------------------
*@@                 VARIABLE COST INTERCEPT AND SLOPE SCALLING
*-------------------------------------------------------------------------------

$if %increasing_costs%=="yes"   variable_cost_intercept(t,p) = 8.268 + mc(t,p) + (-0.57 * %slope% * mc(t,p));

$if %increasing_costs%=="yes"   variable_cost_intercept(t,p)$(%slope% eq 0) = 8.268 + mc(t,p) + (-0.57 * %slope% * mc(t,p));

$if %increasing_costs%=="yes"   variable_cost_slope(t,p)$SUM((scen,year,n,dispatchtech,fuel,is_chp),
$if %increasing_costs%=="yes"                            plant_con(p,scen,year,n,dispatchtech,fuel,is_chp,'MW'))
$if %increasing_costs%=="yes"                                = (%slope% * mc(t,p)) / SUM((scen,year,n,dispatchtech,fuel,is_chp),plant_con(p,scen,year,n,dispatchtech,fuel,is_chp,'MW'));

$if %increasing_costs%=="yes"   variable_cost_slope(t,p)$(SUM(dispatchtech, map_ptech(p,dispatchtech) * variable_cost_slope(t,p)) eq 0) = 0.00001;
$if %increasing_costs%=="yes"   variable_cost_slope(t,p)$(%slope% eq 0) = 0;

$if %increasing_costs%=="no"   variable_cost_intercept(t,p) = 8.268 + mc(t,p);

*-------------------------------------------------------------------------------
*@@                       HYDRO
*-------------------------------------------------------------------------------


* Pump capacity
hydro_pumpcap(n,p)  = SUM((map_np(n,p), map_ptech(p,hydrotech)),cap_pump(n,hydrotech));

* Storage capacity
hydro_storagecap(n,p) = SUM((map_np(n,p), map_ptech(p,hydrotech)),cap_stor(n,hydrotech));
hydro_storagecap("LV",p) = 0 ;


* Dam do not have pump facility
hydro_pumpcap(n,p)$map_ptech(p,'Dam')  = 0;

* Generation Capacity
hydro_capacity(t,n,p)       = SUM((map_np(n,p), map_ptech(p,hydrotech)), q_max(t,p));


* Storage capacity
hydro_storagecap("FI",p) = 0 ;

* Initial storage capacity
initial_stor_ratio(n,'w53',hydrotech) = initial_stor_ratio(n,'w1',hydrotech);
initial_stor_ratio('GR','w53',hydrotech) = initial_stor_ratio('GR','w52',hydrotech);
initial_stor_ratio('GR','w1',hydrotech) = initial_stor_ratio('GR','w52',hydrotech);
initial_stor_ratio('DE',week,hydrotech) = initial_stor_ratio('AT',week,hydrotech);
initial_stor_ratio('PL',week,hydrotech) = initial_stor_ratio('AT',week,hydrotech);
initial_stor_ratio('SK',week,hydrotech) = initial_stor_ratio('SI',week,hydrotech);
initial_stor_ratio('CZ',week,hydrotech) = initial_stor_ratio('AT',week,hydrotech);


initial_storage(n,'%runyear%',week,hydrotech)$((initial_storage(n,'%runyear%',week,hydrotech) gt cap_stor(n,hydrotech)) OR (initial_storage(n,'%runyear%',week,hydrotech) eq 0))
                            = initial_stor_ratio(n,week,hydrotech) * cap_stor(n,hydrotech)
;

hydro_storagelvl_firsthour(tfirst,p)    = SUM(map_tweek(tfirst,week),SUM(map_np(n,p),SUM(map_ptech(p,hydrotech),initial_storage(n,'%runyear%','w1',hydrotech))));
hydro_storagelvl_lasthour(tlast,p)      = SUM(map_tweek(tlast,week),SUM(map_np(n,p),SUM(map_ptech(p,hydrotech),initial_storage(n,'%runyear%','w53',hydrotech))));
hydro_storagelvl_lasthour(tlast,p)$(hydro_storagelvl_lasthour(tlast,p) eq 0) = SUM(tfirst,hydro_storagelvl_firsthour(tfirst,p));

* To avoid infeasibilities because PS Closed does not have inflows
hydro_storagelvl_lasthour(tlast,p)$map_ptech(p,'PSClosed')      = 0;

* If there is no inflows for dams consider it = 0
hydro_capacity(t,"HU","HU_Dam") = 0;
hydro_capacity(t,"LV","LV_Dam") = 0;
hydro_capacity(t,"NO","NO_Dam") = 0;
hydro_capacity(t,"SK","SK_Dam") = 0;
hydro_capacity(t,"FI","FI_Dam") = 0;

inflow(t,"HU",'Dam') = 0;
inflow(t,"LV",hydrotech) = 0;
inflow(t,'NO','Dam') = 0;
inflow(t,'SK','Dam') = 0;
inflow(t,'FI','Dam') = 0;



*-------------------------------------------------------------------------------
*@@                       WRITE GDX INPUT FILE
*-------------------------------------------------------------------------------
Execute_unload "gdx/data_%runyear%.gdx";
