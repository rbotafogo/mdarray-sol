graph = new DCGraph();
graph.convert([\"Date\"]);
// Make variable data accessible to all charts
var data = graph.getData();
//$('#help').append(JSON.stringify(data));
// add data to crossfilter and call it 'facts'.
facts = crossfilter(data);
container = d3.select(\"body\").append(\"div\").attr(\"class\", \"container\").attr(\"style\", \"font: 12px sans-serif;\");

// Add a row for the dashboard title
var title = container.append(\"div\").attr(\"class\", \"row\");
title.attr(\"class\", \"col-sm-12\").attr(\"id\", \"title\").attr(\"align\", \"center\");
title.append(\"h4\")
  .text(\"Complex scene\");

var main = container.append(\"div\").attr(\"class\", \"row\");
main.attr(\"class\", \"col-sm-12\")
var g1_0 = main.append(\"div\").attr(\"class\", \"row\");
var g1_0_0 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
var g1_0_1 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g1_0_1.attr(\"id\", \"DateVolumeChart\");

var g2_0 = g1_0_0.append(\"div\").attr(\"class\", \"row\");
var g2_0_0 = g2_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g2_0_0.attr(\"id\", \"DateOpenChart\");

var g2_1 = g1_0_0.append(\"div\").attr(\"class\", \"row\");
var g2_1_0 = g2_1.append(\"div\").attr(\"class\", \"col-sm-6\");
g2_1_0.attr(\"id\", \"DateCloseChart\");

var TimeDimension = facts.dimension(function(d) {return d[\"Date\"];});
var DateDimension = facts.dimension(function(d) {return d[\"Date\"];});    

var DateOpen = dc.lineChart(\"#DateOpenChart\"); 
var dateopenGroup = DateDimension.group().reduceSum(function(d) {return d[\"Open\"];});

DateOpen
  .dimension(DateDimension)
  .elasticY(true)
  .xAxisLabel(\"Date\")
  .yAxisLabel(\"Open\")
  .group(dateopenGroup)
  .width(600)
  .height(200)
  .x(d3.time.scale().domain([new Date(1357005600000.0), new Date(1366772400000.0)]));    

var DateVolume = dc.barChart(\"#DateVolumeChart\"); 
var datevolumeGroup = TimeDimension.group().reduceSum(function(d) {return d[\"Volume\"];});

DateVolume
  .dimension(TimeDimension)
  .elasticY(true)
  .xAxisLabel(\"Data em dias\")
  .yAxisLabel(\"Volumen em milh\u00F5es (R$)\")
  .group(datevolumeGroup)
  .width(600)
  .height(400)
  .margins({top: 10, right:10, bottom: 50, left: 80})
  .x(d3.time.scale().domain([new Date(1357005600000.0), new Date(1366772400000.0)]));    

var DateHigh = dc.lineChart(\"#DateHighChart\"); 
var datehighGroup = TimeDimension.group().reduceSum(function(d) {return d[\"High\"];});

DateHigh
  .dimension(TimeDimension)
  .elasticY(true)
  .xAxisLabel(\"Time\")
  .yAxisLabel(\"High\")
  .group(datehighGroup)
  .width(600)
  .height(200)
  .x(d3.time.scale().domain([new Date(1357005600000.0), new Date(1366772400000.0)]));

dc.renderAll();







container = d3.select(\"body\").append(\"div\").attr(\"class\", \"container\").attr(\"style\", \"font: 12px sans-serif;\");

// Add a row for the dashboard title
var title = container.append(\"div\").attr(\"class\", \"row\");
title.attr(\"class\", \"col-sm-12\").attr(\"id\", \"title\").attr(\"align\", \"center\");
title.append(\"h4\").text(\"Complex scene\");var main = container.append(\"div\").attr(\"class\", \"row\");
main.attr(\"class\", \"col-sm-12\")
var g1_0 = main.append(\"div\").attr(\"class\", \"row\");
var g1_0_0 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
var g1_0_1 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g1_0_1.attr(\"id\", \"DateVolumeChart\");
var g2_0 = g1_0_0.append(\"div\").attr(\"class\", \"row\");
var g2_0_0 = g2_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g2_0_0.attr(\"id\", \"DateOpenChart\");
var g2_1 = g1_0_0.append(\"div\").attr(\"class\", \"row\");
var g2_1_0 = g2_1.append(\"div\").attr(\"class\", \"col-sm-6\");
g2_1_0.attr(\"id\", \"DateCloseChart\");





container = d3.select(\"body\").append(\"div\").attr(\"class\", \"container\").attr(\"style\", \"font: 12px sans-serif;\");

// Add a row for the dashboard title
var title = container.append(\"div\").attr(\"class\", \"row\");
title.attr(\"class\", \"col-sm-12\").attr(\"id\", \"title\").attr(\"align\", \"center\");
title.append(\"h4\").text(\"Complex scene\");var main = container.append(\"div\").attr(\"class\", \"row\");

main.attr(\"class\", \"col-sm-12\")
var g1_0 = main.append(\"div\").attr(\"class\", \"row\");
var g1_0_0 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g1_0_0.attr(\"id\", \"DateOpenChart\");

var g1_0_1 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g1_0_1.attr(\"id\", \"DateVolumeChart\");

var g1_1 = main.append(\"div\").attr(\"class\", \"row\");
var g1_1_0 = g1_1.append(\"div\").attr(\"class\", \"col-sm-6\");
g1_1_0.attr(\"id\", \"DateHighChart\");

var g1_1_1 = g1_1.append(\"div\").attr(\"class\", \"col-sm-6\");
g1_1_1.attr(\"id\", \"__bootstrap_empty__Chart\")



container = d3.select(\"body\").append(\"div\").attr(\"class\", \"container\").attr(\"style\", \"font: 12px sans-serif;\");

// Add a row for the dashboard title
var title = container.append(\"div\").attr(\"class\", \"row\");
title.attr(\"class\", \"col-sm-12\").attr(\"id\", \"title\").attr(\"align\", \"center\");
title.append(\"h4\").text(\"Complex scene\");

var main = container.append(\"div\").attr(\"class\", \"row\");
main.attr(\"class\", \"col-sm-12\")

var g1_0 = main.append(\"div\").attr(\"class\", \"row\");
var g1_0_0 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
var g1_0_1 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g1_0_1.attr(\"id\", \"DateVolumeChart\");

var g2_0 = g1_0_0.append(\"div\").attr(\"class\", \"row\");
var g2_0_0 = g2_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g2_0_0.attr(\"id\", \"DateOpenChart\");

var g2_1 = g1_0_0.append(\"div\").attr(\"class\", \"row\");
var g2_1_0 = g2_1.append(\"div\").attr(\"class\", \"col-sm-6\");
g2_1_0.attr(\"id\", \"DateCloseChart\");




container = d3.select(\"body\").append(\"div\").attr(\"class\", \"container\").attr(\"style\", \"font: 12px sans-serif;\");

// Add a row for the dashboard title
var title = container.append(\"div\").attr(\"class\", \"row\");
title.attr(\"class\", \"col-sm-12\").attr(\"id\", \"title\").attr(\"align\", \"center\");
title.append(\"h4\").text(\"Complex scene\");

var g1_0 = container.append(\"div\").attr(\"class\", \"row\");
var g1_0_0 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
var g1_0_1 = g1_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g1_0_1.attr(\"id\", \"DateVolumeChart\");

var g2_0 = g1_0_0.append(\"div\").attr(\"class\", \"row\");
var g2_0_0 = g2_0.append(\"div\").attr(\"class\", \"col-sm-6\");
g2_0_0.attr(\"id\", \"DateOpenChart\");

var g2_1 = g1_0_0.append(\"div\").attr(\"class\", \"row\");
var g2_1_0 = g2_1.append(\"div\").attr(\"class\", \"col-sm-6\");
g2_1_0.attr(\"id\", \"DateCloseChart\");
