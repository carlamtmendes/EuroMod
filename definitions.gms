*###############################################################################
*@                           DEFINITIONS
*###############################################################################

$if not set report_prefix       $setglobal      report_prefix "report"

*-----------------------------------------------------------------------*
*@@                 SCALARS, SETS, ALIAS, and PARAMETERS                *
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*                              Scalars                                  *
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*                               Sets                                    *
*-----------------------------------------------------------------------*


Sets

****sets for reporting*************************************************
        item_rep                                        Items are mainly for reporting but must be defined here
                             /"Error: CheckSum!","CO2 tonnes",Price, Margin, MarginHydro,LostLoad,LostGeneration,Demand,Supply,PumpDemand,Curtailment,NetImport,Demand_Mobility,Intercept, Slope, Biomass, Coal, Hydro, Gas, Oil, Other, Dam, PSClosed, PSOpen, PSP, RoR, Solar, WindOn, Nuclear, WindOff, Lignite, AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, GB, GR, HR, HU, IE, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, SK/
        
        item(item_rep)                                  Items are mainly for reporting 
                             /"Error: CheckSum!","CO2 tonnes",LostLoad,LostGeneration,Demand,PumpDemand,Curtailment,NetImport,Demand_Mobility,Biomass, Coal, Hydro, Gas, Oil, Other, Dam, PSClosed, PSOpen, PSP, RoR, Solar, WindOn, Nuclear, WindOff, Lignite/

****sets in model setup**************************************************
        all_t                                           all hours                   /1*8760/
        t(all_t)                                        hours used in the model     /%t_start% * %t_end%/
        tfirst(t)                                       first period
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


****sets for time blocks*************************************************
        time                                            timestep
        month                                           month
        day                                             day
        hour                                            hour
        week                                            week
        quarter                                         quarters of the year            /1*4/

****sets for data import*************************************************
        fuel                                            fuel


****sets for scenarios*************************************************
        scen                                            scenarios TYNDP
        
****sets for mapping***************************************************
        map_np(n,p)                                     mapping nodes to power plants
        map_pchp(p)                                     mapping plants to must run plants
        map_ptech(p,tech)                               mapping plants to technologies
        map_pfuel(p,fuel)                               mapping plants to fuel
        map_techfuel(tech,fuel)                         mapping technologies to fuel
        map_tyear(t,year)                               mapping model hours to year
        map_tmonth(t,month)                             mapping model hours to months
        map_tweek(t,week)                               mapping model hours to weeks
        map_ttime(t,time)                               mapping model hours to timesteps
        map_tquarter(t,quarter)                         mapping model hours to yearly quarters

;

*-----------------------------------------------------------------------*
*                              Alias                                    *
*-----------------------------------------------------------------------*

Alias (n,nn);

Alias (t,tt);

Sets
        map_l_n_nn(l,n,nn)                              mapping lines to nodes
        ntc_line(n,nn)                                  ntc lines
;



*-----------------------------------------------------------------------*
*                        Defining Parameters                            *
*-----------------------------------------------------------------------*

Parameters
        d(t,n)                                     load per node and t

        infeed(t,tech,n)                           res infeed per technology, node and t
        infeed_sum(t,n)                            total res infeed per node and t

        q_max(t,p)                                 maximum capacity for power plants taking into account availabilities
        availablity(n,tech,month)                  power plant availabilities per country tech and month

        hydro_capacity(t,n,p)                      Hydro capacity per hydro tech
        hydro_storagecap(n,p)                      Storage capacity for Dam and PSP
        hydro_pumpcap(n,p)                         Storage capacity for pump
        inflow(t,n,hydrotech)                      water inflows 

        fuel_price_eu(t,fuel,eu)                   fuel price per fuel and t for EU countries
        fuel_price_gb(t,fuel,noneu)                fuel price per fuel and t for GB countries

        co2_price_eu(t,eu)                         co2 prices for EU countries
        co2_price_gb(t,noneu)                      co2 prices for GB
        co2_intensity(tech)                        co2 intensity by technology

        cap_ntc(t,n,nn)                            ntc capacity from node A to B

*  Quadratic cost function calculation
        mc(t,p)                                    marginal cost without bid spread in EUR per MWh
        variable_cost_intercept(t,p)               Variable cost intercept in EUR per MWh
        variable_cost_slope(t,p)                   Variable cost slope in (EUR per MWh) per MWh

* CHP

        chp_energy_year(n,year)                    generation from chp [MWh]
        total_capacity_country(n)                  max chp capacity per country[MW]
        q_max_tot(p,n)                             total max chp capacity per country and power plant[MW]
        p_share_in_q_max_tot(p,n)                  share of single power plant capacity in total capacity per country and technology[%]
        chp_demand_year(p,n)                       yearly chp demand distributed per power plant[MWh]     
        chp(t,p)                                   minimum must run (chp) capacity[MWh]
        chp_dem_country(t,n,p)                     chp demand per country power plant and time
        chp_infes(t,p)                             check infeasibilities if chp is greater than max capacity 
        adjust_chp(n)                              scaling of chp demand to not exceed 30 of demand
        
* Others
        net_demand(t,n)                            net-demand per hour and country
        net_demand_avg(n)                          net-demand average per country 
        net_demand_std(n)                          net-demand standard deviation per country 

;




*###############################################################################
*@                           MODEL DEFINITIONS
*###############################################################################

*-----------------------------------------------------------------------*
*                              VARIABLES                                *
*-----------------------------------------------------------------------*

Variables
         COST                                    total costs [EUR]
;

Positive Variables

        Q(t,p)                                   total generation by conventional power plants [MWh]

        TURB(t,p)                                power generation by hydro power plants [MWh]
        PUMP(t,p)                                pumping by hydro power plants [MWh]
        Storlevel(t,p)                           storage level per country for hydro plants [MW]
        SPILL(t,p)                               storage spill

        LostLoad(t,n)                            Lost load
        LostGeneration(t,n)                      lost generation (similar to curtailing but costly)
        Curtailment(t,n)                         curtailment

        NTCFLOW(t,n,nn)                          NTC power flow [MWh]
        
;


*-----------------------------------------------------------------------*
*                              EQUATIONS                                *
*-----------------------------------------------------------------------*

Equations
*        Objective function
         OBJ_cost                                objective function minimizing costs

*        Energy balance
         DEF_energy(t,n)                         energy balance definition
         LIM_lostload(t,n)                       lost load must be smaller than nodal load (demand)

*        Curtailment
         LIM_curtailment(t,n)                    curtailment constraint

*        Generation
         LIM_qchp(t,p)                           CHP minimum generation constriant
         LIM_qmax(t,p)                           Capacity restriction

*        Hydro Generation
         LIM_turb(t,p)                           maximum hydro generation restriction
         LIM_pump(t,p)                           maximum pumping restriction
         LIM_Storlevel(t,p)                      maximum storage restriction
         DEF_Storlevel(t,p)                      storage balance

*        Network
         LIM_ntc(t,n,nn)                         ntc powerflow constraint


;
