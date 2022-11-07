************************************************************************
* This should be either "arregate" or "report"
$set report_prefix    %1

*  This can be "with_dimensions" or "without_dimensions"
$set paramlist_mode   %2


$if %paramlist_mode%=="without_dimensions" $inlineCom ( )

$set scenariodimension  %3


$if not set reporting_command $setglobal reporting_command ""

************************************************************************


* Hourly
    %report_prefix%_nodal_price_hourly(t,n %scenariodimension%)  %reporting_command%
    
    %report_prefix%_hourly(t,n,item_rep %scenariodimension%)  %reporting_command%
    %report_prefix%_ntcflow(t,n,nn %scenariodimension%)  %reporting_command%
    %report_prefix%_storlevel_hourly(t,n %scenariodimension%)  %reporting_command%
    %report_prefix%_ntcflow_exp(t,n %scenariodimension%)  %reporting_command%
    %report_prefix%_ntcflow_imp(t,n %scenariodimension%)  %reporting_command%
    results(t,n,item_rep %scenariodimension%)  %reporting_command%

* Statistics
    %report_prefix%_statistics(report_statistics_item %scenariodimension%)  %reporting_command%

************************************************************************
$if %paramlist_mode%=="without_dimensions" $offInline
************************************************************************
