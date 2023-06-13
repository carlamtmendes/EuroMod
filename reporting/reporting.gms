*----------------------------------------------------------------------------------
* Hourly reporting
*----------------------------------------------------------------------------------

report_ntcflow_exp(t,n)   =  SUM(nn, NTCFLOW.L(t,n,nn)) + EPS;

report_ntcflow_imp(t,n)   =  SUM(nn, (1-ntc_loss(nn,n)) * NTCFLOW.L(t,nn, n)) + EPS;

report_ntcflow(t,n,nn)    = ((1-ntc_loss(nn,n)) * NTCFLOW.L(t,nn,n)) - NTCFLOW.L(t,n,nn) + EPS;

report_nodal_price_hourly(t,n)          = - DEF_energy.M(t,n) * %scale% + EPS;

report_hourly(t,n, "Demand")            = - d(t,n) + EPS;

report_hourly(t,n, "Curtailment")       = - Curtailment.L(t,n) + EPS;

report_hourly(t,n, "LostGeneration")    = - LostGeneration.L(t,n) + EPS;

report_hourly(t,n, "LostLoad")          =  LostLoad.L(t,n) + EPS;

report_hourly(t,n, dispatchtech)        =  SUM(map_np(n,p), SUM(map_ptech(p,dispatchtech),Q.L(t,p))) + EPS;

report_hourly(t,n, hydrotech)           =  SUM(map_np(n,p), SUM(map_ptech(p,hydrotech),TURB.L(t,p))) + EPS;

report_hourly(t,n, restech)             =  infeed(t,restech,n) + EPS;

report_hourly(t,n, "PumpDemand")        = - SUM((map_np(n,p), hydrotech), SUM(map_ptech(p,hydrotech), PUMP.L(t,p))) + EPS;

report_hourly(t,n, "NetImport")         = report_ntcflow_imp(t,n) - report_ntcflow_exp(t,n);



* Sum over all items above and calculate the checksum
report_hourly(t,n, "Error: CheckSum!")    =  SUM(item, report_hourly(t,n,item)) + EPS;
report_hourly(t,n, "Error: CheckSum!")$(report_hourly(t,n, "Error: CheckSum!") lt 0.01 AND report_hourly(t,n, "Error: CheckSum!") gt -0.01) = 0;

report_storlevel_hourly(t,n)              = SUM(map_np(n,p), Storlevel.L(t,p)) + EPS;

report_hourly(t, n, "CO2 tonnes")         = SUM(tech, report_hourly(t,n,tech) * co2_intensity(tech));


* UPDATE QCP PRICES WITH POST-PROCESSING TRANSFORMATION

net_demand(t,n)         = d(t,n) - infeed(t,'Solar',n) - infeed(t,'WindOn',n) - infeed(t,'WindOff',n);
net_demand_avg(n)       = SUM(t,net_demand(t,n)) / 8760;
net_demand_std(n)       = sqrt(SUM(t, sqr(net_demand(t,n)-net_demand_avg(n)))/(8760-1));


* QUANTILES

* Quantiles prices per country

* Evaluate means and support for results:
qvalue_model_country(n,"mean") =  sum(t, report_nodal_price_hourly(t,n))/card(t);

* Determine ranking of sectors by mean impact:
mean_model_country(n) = qvalue_model_country(n,"mean");

$libInclude rank mean_model_country n meanrank_country

* The following statement creates a tuple matching the ordered
* set, ki, to the set of country, n.  In this tuple, the sequence of
* assignments corresponds to increasing mean impacts: 
*imap(ki+(meanrank(n)-ord(ki)),n) = yes;

* Evaluate quartiles of sectoral impacts for each country:
loop(n,
   x_model(t) = report_nodal_price_hourly(t,n);

*  Load quartile with the perctiles to be
*  evaluated (10th, 50th and 90th):
   quartile_model(qtl) = qv_model(qtl);

$  libInclude rank x_model t r_model quartile_model

*  Save the quartile values:
   qvalue_model_country(n,qtl) = quartile_model(qtl);
);

report_price_quantile_model_country(n,qtl)    = qvalue_model_country(n,qtl);


results(t,n,item_rep) = report_hourly(t,n,item_rep);
results(t,n,'Demand') = - report_hourly(t,n,'Demand');
results(t,n,'Curtailment') = - report_hourly(t,n,'Curtailment');
results(t,n,"LostGeneration") = - report_hourly(t,n,"LostGeneration");
results(t,n,"PumpDemand") = - report_hourly(t,n,"PumpDemand");
results(t,n,'Supply') = SUM(dispatchtech,report_hourly(t,n, dispatchtech)) + SUM(hydrotech, report_hourly(t,n, hydrotech)) + SUM(restech, report_hourly(t,n, restech));

* EuroMod Prices with adjustment
results(t,n,'Price') = report_nodal_price_hourly(t,n) + (((net_demand(t,n) - net_demand_avg(n))/ (net_demand_std(n))) * beta * SUM(qtl,report_price_quantile_model_country(n,qtl)));

results(t,n,nn) = report_ntcflow(t,n,nn);

*----------------------------------------------------------------------------------
* Statistics
*----------------------------------------------------------------------------------

report_statistics("Benchmark: Solve CPU hours") = %modelName%.resusd/60/60;
report_statistics("Benchmark: Solve real hours") = %modelName%.etSolver/60/60;
report_statistics("Benchmark: TimeComp hours") = TimeComp/60/60;
report_statistics("Benchmark: TimeExec hours") = TimeExec/60/60;
report_statistics("Benchmark: TimeElapsed hours") = TimeElapsed/60/60;
report_statistics("Solve: Number of variables") = %modelName%.numVar;
report_statistics("Solve: Number of discrete variables") = %modelName%.numDVar;
report_statistics("Solve: Number of equations") = %modelName%.numEqu;
report_statistics("Solve: ModelStat") = %modelName%.modelStat;
report_statistics("Solve: SovelStat (should be 1)") = %modelName%.solveStat;
report_statistics("Solve: Number of infeasibilities") = %modelName%.numInfes;
report_statistics("GAMS license level (0=demo,1=full,2+3=very limited)") = licenseLevel;
report_statistics("GAMS number of execErrors") = execError;
report_statistics("Objective") = COST.L;
report_statistics("Objective scaling factor") = %scale%;


*----------------------------------------------------------------------------------
* Write output
*----------------------------------------------------------------------------------
$if %increasing_costs%=="no"    Execute_unload "results/Result_GAMS_%result_file_suffix%_LP.gdx";
$if %increasing_costs%=="yes"   Execute_unload "results/Result_GAMS_%result_file_suffix%_QCP.gdx";

Execute 'gdxdump results/Result_GAMS_%result_file_suffix%_QCP.gdx format=csv output=results/results_%result_file_suffix%.csv symb=results cDim=y EpsOut=0 ';
