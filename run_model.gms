*###############################################################################
*@                             RUN MODEL DEFINITIONS
*###############################################################################

*------------------------------------------------------------------------------*
*                             Global options                                   *
*------------------------------------------------------------------------------*

* Set star to either use excel or gdx dataload
$setglobal Excel_dataload "*"
$setglobal GDX_dataload ""


* Define start and end hours

$if not set t_start                     $setglobal t_start                      1
$if not set t_end                       $setglobal t_end                        8760
$if not set runyear                     $setglobal runyear                      2017
$if not set solver                      $setglobal solver                       CPLEX
$if not set modelName                   $setglobal modelName                    Euromod

** CHOOSE SCENARIO
$if not set scenario                    $setglobal scenario                     Historic

$if not set scale                       $setglobal scale                        1000
$if not set lostload_price              $setglobal lostload_price               10000
$if not set curtail_price               $setglobal curtail_price                65

** CHOOSE MODULES
$if not set module_calibration          $setglobal module_calibration           yes
$if not set module_chp                  $setglobal module_chp                   yes

$if not set slope                       $setglobal slope                        0.47

$if not set result_file_suffix          $setglobal result_file_suffix           %scenario%_t%t_end%

** CHOOSE RUN LP OR QCP: no/yes
$if not set increasing_costs            $setglobal increasing_costs             yes

*------------------------------------------------------------------------------*
*                             Solver options                                   *
*------------------------------------------------------------------------------*
option

dispwidth = 15,
limrow = 12000,
limcol = 12000,
solprint = on,
sysout = on ,
reslim = 10000000 ,
iterlim = 10000000 ,
threads = -1,
QCP = %solver%,
LP = %solver%
;

*-------------------------------------------------------------------------------
*                               definitions
*-------------------------------------------------------------------------------

$INCLUDE definitions.gms

*-------------------------------------------------------------------------------
*                               upload data
*-------------------------------------------------------------------------------

$INCLUDE read_data.gms

*-------------------------------------------------------------------------------
*                                model
*-------------------------------------------------------------------------------

$INCLUDE model.gms

*-------------------------------------------------------------------------------*
*                                Execution                                      *
*-------------------------------------------------------------------------------*

****Solve and output*****************************************************

$if %increasing_costs%=="no" solve Euromod using LP minimizing COST                     ;
$if %increasing_costs%=="yes" solve Euromod using QCP minimizing COST                   ;

*-------------------------------------------------------------------------------*
*                                Reporting                                      *
*-------------------------------------------------------------------------------*

$setglobal report_prefix "report"
$include reporting/reporting_definitions.gms
$include reporting/reporting.gms
