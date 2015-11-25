graph = new DCGraph();
graph.convert([]);
// Make variable data accessible to all charts
var data = graph.getData();
//$('#help').append(JSON.stringify(data));
// add data to crossfilter and call it 'facts'.
facts = crossfilter(data);
container = d3.select(\"body\").append(\"div\").attr(\"class\", \"container\").attr(\"style\", \"font: 12px sans-serif;\");

// Add a row for the dashboard title
var title = container.append(\"div\").attr(\"class\", \"row\");
title.attr(\"class\", \"col-sm-12\")
  .attr(\"id\", \"title\")
  .attr(\"align\", \"center\");

var main = container.append(\"div\").attr(\"class\", \"row\");
main.attr(\"class\", \"col-sm-12\")

var g1_0 = main.append(\"div\").attr(\"class\", \"row\");
var g1_0_0 = g1_0.append(\"div\").attr(\"class\", \"col-sm-12\");

var RunDimension = facts.dimension(function(d) {return d[\"Run\"];});    

var RunSpeed = dc.lineChart(\"#RunSpeedChart\"); 
var runspeedGroup = RunDimension.group().reduceSum(function(d) {return d[\"Speed\"];});

RunSpeed
  .dimension(RunDimension)
  .elasticY(true)
  .xAxisLabel(\"Run\")
  .yAxisLabel(\"This is the Y Axis!\")
  .group(runspeedGroup)
  .width(768)
  .height(480)
  .x(d3.scale.linear().domain([1, 20]))
  .margins({top: 10, right: 10, bottom: 20, left: 50 });

dc.renderAll();"


