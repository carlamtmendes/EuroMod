*-----------------------------------------------------------------------*
*                        Reporting                                      *
*-----------------------------------------------------------------------*

$if not set report_prefix       $setglobal report_prefix        "report"
$if not set scenariodimension   $setglobal scenariodimension    ""


$if NOT %report_prefix%=="report" $goto afterStatisticItems

Set
         %report_prefix%_statistics_item
               /
                  "Benchmark: TimeElapsed hours"
                  "Benchmark: Solve CPU hours"
                  "Benchmark: Solve real hours"
                  "Benchmark: TimeComp hours"
                  "Benchmark: TimeExec hours"
                  "Solve: Number of variables"
                  "Solve: Number of discrete variables"
                  "Solve: Number of equations"
                  "Solve: ModelStat"
                  "Solve: SovelStat (should be 1)"
                  "Solve: Number of infeasibilities"
                  "GAMS license level (0=demo,1=full,2+3=very limited)"
                  "GAMS number of execErrors"
                  "Objective"
                  "Objective scaling factor"
                  "BSSmin t"
               /

;

$label afterStatisticItems

Parameters
* General information
$batinclude reporting/report_definitions_paramlist.gms %report_prefix% with_dimensions "%scenariodimension%"
;
