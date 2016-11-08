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

require '../../config' if @platform == nil
require 'mdarray-sol'

require_relative 'scale'
require_relative 'axes'

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
  # Initialize the scatterplot and create the main svg for the plot with the given
  # width and height and padding
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
  # Defines the style for the labels in the plot
  #--------------------------------------------------------------------------------------

  def style
    Proc.new do |g|
      g.attr("font-family", "sans-serif")
      g.attr("font-size", "10px")
      g.attr("fill", "gray")
    end
  end
    
  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def plot
    
    x_min, x_max = @dataset.minmax_by { |d| d[0] }
    y_min, y_max = @dataset.minmax_by { |d| d[1] }
    
    x_scale = Scale.new([0, x_max[0]], [@padding, @width - @padding * 2])
    y_scale = Scale.new([0, y_max[1]], [@height - @padding, @padding])

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
      .attr("color", "gray")
      .attr("r", 3)
  end

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def add_labels(x_scale, y_scale)
    @svg.selectAll("text")
      .data(@dataset)
      .enter(nil)
      .append("text")
      .call(&style)
      .text { |d, i| "(#{d[0].to_i}, #{d[1].to_i})" }
      .attr("x") { |d, i| x_scale[d[0]] }
      .attr("y") { |d, i| y_scale[d[1]] }
  end

end

