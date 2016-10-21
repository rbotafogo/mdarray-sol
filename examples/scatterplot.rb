# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2016 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require '../config' if @platform == nil
require 'mdarray-sol'

#=========================================================================================
#
#=========================================================================================

class Scale

  attr_reader :scale

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def initialize(domain, range)
    @scale = $d3.scale.linear(nil)
    @scale
      .domain(domain)
      .range(range)
  end

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def[](val)
    @scale[val]
  end
    
end

#=========================================================================================
#
#=========================================================================================

class Axes

  attr_reader :chart
  attr_reader :x_axis
  attr_reader :y_axis
  
  #--------------------------------------------------------------------------------------
  # Creates the x and y axes for a chart.
  # chart: the chart for which the axes should be added
  # x_scale: the x scale for the x axis
  # y_scale: the y scale for the y axis
  #--------------------------------------------------------------------------------------

  def initialize(chart, x_scale, y_scale)

    @chart = chart
    @x_axis = $d3.svg.axis(nil)
    @y_axis = $d3.svg.axis(nil)

    @x_axis.scale(x_scale)
      .orient("bottom")
    
    @y_axis.scale(y_scale)
      .orient("left")
    
  end

  #--------------------------------------------------------------------------------------
  # Plot the x and y axis
  #--------------------------------------------------------------------------------------

  def plot
    
    # add x_axis
    @chart.svg.append("g")
      .attr("class", "axis")
      .attr("transform", "translate(0, #{@chart.height - @chart.padding})")
      .attr("fill", "none")
      .attr("stroke", "black")
      .attr("shape-rendering", "crispEdges")
      .call(@x_axis)

    # This call is calling method 'map' on a java JSArray.  This should somehow be
    # converted to a javascript array!!!!
      # .call{|g| g.attr("fill", "none")}

    # add y_axis
    @chart.svg.append("g")
      .attr("class", "axis")
      .attr("transform", "translate(#{@chart.padding}, 0)")
      .attr("fill", "none")
      .attr("stroke", "black")
      .attr("shape-rendering", "crispEdges")
      .call(@y_axis);    
  end
  
end

#=========================================================================================
#
#=========================================================================================

class ScatterPlot

  attr_reader :dataset
  attr_reader :width
  attr_reader :height
  attr_reader :svg
  attr_reader :padding

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------
  
  def initialize(dataset, width:, height:, padding:)
    @dataset = dataset
    @width = width
    @height = height
    @padding = padding

    @svg = $d3.select("body")
           .append("svg")
           .attr("width", @width)
           .attr("height", @height)
  end

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def plot
    
    x_min, x_max = @dataset.minmax_by { |d| d[0] }
    y_min, y_max = @dataset.minmax_by { |d| d[1] }
    
    x_scale = Scale.new([0, x_max[0]], [@padding, @width - @padding * 2])
    y_scale = Scale.new([0, y_max[0]], [@height, 0])

    add_data(x_scale, y_scale)
    add_labels(x_scale, y_scale)

    axes = Axes.new(self, x_scale.scale, y_scale.scale)
    axes.plot
    
  end

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def add_data(x_scale, y_scale)
    @svg.selectAll("circle")
      .data(@dataset)
      .enter(nil)
      .append("circle")
      .attr("cx") { |d, i| x_scale[d[0]] }
      .attr("cy") { |d, i| y_scale[d[1]] }
      .attr("r", 5)
  end

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def add_labels(x_scale, y_scale)
    @svg.selectAll("text")
      .data(@dataset)
      .enter(nil)
      .append("text")
      .text { |d, i| "(#{d[0].to_i}, #{d[1].to_i})" }
      .attr("x") { |d, i| x_scale[d[0]] }
      .attr("y") { |d, i| y_scale[d[1]] }
      .attr("font-family", "sans-serif")
      .attr("font-size", "11px")
      .attr("fill", "red");
  end

end

dataset = [
  [5, 20], [480, 90], [250, 50], [100, 33], [330, 95],
  [410, 12], [475, 44], [25, 67], [85, 21], [220, 88]
]

splot = ScatterPlot.new(dataset, width: 500, height: 300, padding: 20)
splot.plot

