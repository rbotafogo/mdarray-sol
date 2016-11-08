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
      .ticks(5)
    
    @y_axis.scale(y_scale)
      .orient("left")
      .ticks(5)
    
  end

  #--------------------------------------------------------------------------------------
  # Set the style of the axes
  #--------------------------------------------------------------------------------------

  def style
    Proc.new do |g|
      g.attr("fill", "none")
      g.attr("stroke", "gray")
      g.attr("shape-rendering", "crisEdges")
      g.attr("font-family", "sans-serif")
      g.attr("font-size", "11px")
    end
  end
  
  #--------------------------------------------------------------------------------------
  # Plot the x and y axis
  #--------------------------------------------------------------------------------------

  def plot

    # add x_axis
    @chart.svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0, #{@chart.height - @chart.padding})")
      .call(&style)
      .call(@x_axis)

    # add y_axis
    @chart.svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(#{@chart.padding}, 0)")
      .call(&style)
      .call(@y_axis)

  end
  
end
