*###############################################################################
*@                             MODEL DEFINITION
*###############################################################################

$setglobal t "t"

*-------------------------------------------------------------------------------
*@@                              OBJECTIVE
*-------------------------------------------------------------------------------
*        Minimize total cost of conventional generation
*note:   this equation does not include balancing by conventional power plants
*note2:  costs for curtailment are included
*note3:  variable_cost_intercept includes bid spread

OBJ_cost..
      COST     =E=                                 (
                                                        SUM((t,p)$(SUM(dispatchtech, map_ptech(p,dispatchtech) * q_max(t,p))),
                                                                    ( variable_cost_intercept(t,p)
$if %increasing_costs%=="yes"                                           + (variable_cost_slope(t,p) * Q(t,p))
                                                                    ) * Q(t,p)

                                                        )
                                                        + SUM((t,n), %lostload_price% * (LostLoad(t,n) + LostGeneration(t,n)))
                                                        + SUM((t,n), %curtail_price% * Curtailment(t,n))
                                                   )
                                                   /%scale%
;
*-------------------------------------------------------------------------------
*@@                            MARKET CLEARING
*-------------------------------------------------------------------------------
*        Nodal energy balance excluding balancing
DEF_energy(t,n)..
      0  =E=
              SUM(map_np(n,p)$(SUM(dispatchtech, map_ptech(p,dispatchtech) * q_max(t,p))), Q(t,p))
              + SUM(restech, infeed(t,restech,n))
              + SUM(p$(SUM(hydrotech, map_ptech(p,hydrotech) * hydro_capacity(t,n,p))),TURB(t,p))
              - SUM(p$(SUM(hydrotech$(not sameas(hydrotech,'Dam')), map_ptech(p,hydrotech) * hydro_capacity(t,n,p))), PUMP(t,p))
              - d(t,n)
              + SUM(nn$(ntc_line(n,nn) * cap_ntc(t,n,nn)), ((1-ntc_loss(nn,n)) * NTCFLOW(t,nn,n)) - NTCFLOW(t,n,nn))
              + LostLoad(t,n)
              - LostGeneration(t,n)
              - Curtailment(t,n)$SUM(restech, infeed(t,restech,n))
;

*        Curtailment constraint
LIM_curtailment(t,n)$SUM(restech, infeed(t,restech,n))..
         Curtailment(t,n)    =L=     SUM(restech, infeed(t,restech,n))
;

LIM_lostload(t,n)..
         LostLoad(t,n)       =L=     d(t,n)
;                        

*-------------------------------------------------------------------------------
*@@                       CONVENTIONAL GENERATION
*-------------------------------------------------------------------------------

$IF NOT %module_chp%=="yes" $goto end_chp
*        CHP constraint
LIM_qchp(t,p)$(SUM(dispatchtech, map_ptech(p,dispatchtech) * q_max(t,p)))..
         Q(t,p)           =G=     chp(t,p)
;
$label end_chp

*        Generation capacity constraint for conventional power plants
LIM_qmax(t,p)$(SUM(dispatchtech, map_ptech(p,dispatchtech) * q_max(t,p)))..
         Q(t,p)           =L=     q_max(t,p)
;

*-------------------------------------------------------------------------------
*@@                            HYDRO
*-------------------------------------------------------------------------------

*@@@ ------------------------- ALL HYDRO TECHNOLOGIES --------------------------
*        Generation capacity constraint for hydro
LIM_TURB(t,p)$SUM((n,map_ptech(p,hydrotech)),hydro_capacity(t,n,p))..
         TURB(t,p)
                         =L=     SUM(n,hydro_capacity(t,n,p))
;

*        Pump capacity constraint for hydro plants
LIM_PUMP(t,p)$SUM(n,SUM(map_ptech(p,hydrotech)$(not sameas(hydrotech,'Dam')),hydro_pumpcap(n,p)))..
         PUMP(t,p)
                         =L=     SUM(n,hydro_pumpcap(n,p))
;


*        Storage constraint for hydro plants
LIM_Storlevel(t,p)$SUM((n,map_ptech(p,hydrotech)),hydro_storagecap(n,p))..
         Storlevel(t,p)
                         =L=     SUM(n,hydro_storagecap(n,p))
;


*        Storage balance for hydro

DEF_Storlevel(t,p)$SUM((n,map_ptech(p,hydrotech)),hydro_storagecap(n,p))..
         Storlevel(t,p)
                         =E=     Storlevel(t-1,p)
                                 +  0.75 * PUMP(t,p)$SUM(n,SUM(map_ptech(p,hydrotech)$(not sameas(hydrotech,'Dam')),hydro_pumpcap(n,p)))
                                 +  SUM(tfirst,hydro_storagelvl_firsthour(tfirst,p))$(ord(t) eq 1)
                                 -  TURB(t,p)
                                 +  SUM(map_np(n,p),SUM(map_ptech(p,hydrotech), inflow(t,n,hydrotech)))                                
                                 -  SPILL(t,p)
                                 
;

*-------------------------------------------------------------------------------
*@@                        ELECTRICITY GRID
*-------------------------------------------------------------------------------

LIM_ntc(t,n,nn)..

         NTCFLOW(t,n,nn)    =L=    cap_ntc(t,n,nn)

;


*###############################################################################
*@                             MODEL ASSIGNMENT
*###############################################################################

Model Euromod /
         OBJ_cost
         DEF_energy
         LIM_curtailment
         LIM_lostload
         LIM_qmax

$if %module_chp%=="yes"           LIM_qchp
 
        LIM_TURB
        LIM_PUMP
        LIM_Storlevel
        DEF_Storlevel
        LIM_ntc

/;


Euromod.optfile  = 0;
Euromod.dictfile = 0;

*###############################################################################
*@                       VARIABLE FIXING AND BOUNDS
*###############################################################################
$IF %scenario%=="Historic"                  Storlevel.LO(tlast,p)$(hydro_storagelvl_lasthour(tlast,p) AND NOT map_ptech(p,'PSClosed')) = hydro_storagelvl_lasthour(tlast,p);
