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

  attr_accessor :type
  attr_accessor :domain
  attr_accessor :range

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

  attr_reader :axes
  
  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def initialize(x_min, x_max, y_min, y_max)
    @x_scale = Scale.new([x_min, x_max])
    @y_scale = Scale.new
  end

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def build

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

