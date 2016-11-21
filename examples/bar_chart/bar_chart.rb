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

class BarChart

  attr_reader :dataset
  attr_reader :width
  attr_reader :height
  attr_reader :svg
  attr_reader :padding
  attr_reader :scale

  #--------------------------------------------------------------------------------------
  # Initialize the bar chart and create the main svg for the plot with the given
  # width and height and padding
  #
  # @param dataset [Array] an array of points in the form of [x, y]
  # @param width [Number] the width of the plot
  # @param height [Number] the height of the plot
  # @param padding [Number] a padding for the plot. Uses the same padding for x and y
  # dimension. Could be improved by adding different paddings for x and y
  #--------------------------------------------------------------------------------------
  
  def initialize(dataset, width:, height:, padding:)
    @dataset = dataset
    @width = width
    @height = height
    @padding = padding
    @scale = Scale.new([*0..@dataset.length], @width)

    @svg = $d3.select("body")
           .append("svg")
           .attr("width", @width)
           .attr("height", @height)
  end

  #--------------------------------------------------------------------------------------
  # @param scale [Scale] the scale for the data, this is a Scale object that
  # encapsulates the scale function from d3.  scale defauts to the bar chart scale.
  # Usually this will always be the case, but we need to set it since scale is used
  # inside a block
  #--------------------------------------------------------------------------------------

  def add_data(scale = @scale)

    length = @dataset.length
    width = @width
    height = @height
    padding = @padding

    @svg.selectAll("rect")
      .data(@dataset)
      .enter(nil)
      .append("rect")
      .attr("x") { |d, i| scale[i]}
      .attr("y") { |d, i| height - (d[:value] * 4) }
      .attr("width", scale.scale.rangeBand(nil))
      .attr("height") { |d, i| (d[:value] * 4) }
      .attr("fill") { |d, i| "rgb(0, 0, #{(d[:value] * 10).to_i})" }

    style = {"font-family" => "sans-serif",
             "font-size" => "11px",
             "fill" => "white",
             "text-anchor" => "middle"}
    
    @svg.selectAll("text")
      .data(@dataset)
      .enter(nil)
      .append("text")
      .text { |d, i| d[:value] }
      .attr({"x"=> ->(d, i, z) {scale[i] + scale.scale.rangeBand(nil) / 2},
             "y"=> ->(d, i, z) {height - (d[:value] * 4) + 14 }})
      .attr(style)
    
  end
  
  #--------------------------------------------------------------------------------------
  # Plots the bar chart
  #--------------------------------------------------------------------------------------

  def plot
    add_data(nil)
  end
  
  
end

# Let´s work with a dataset that has key, value pairs

dataset = [ {key: 0, value: 5}, {key: 1, value: 10},
            {key: 2, value: 13}, {key: 3, value: 19},
            {key: 4, value: 21}, {key: 5, value: 25},
            {key: 6, value: 22}, {key: 7, value: 18},
            {key: 8, value: 15}, {key: 9, value: 13},
            {key: 10, value: 11}, {key: 11, value: 12},
            {key: 12, value: 15}, {key: 13, value: 20},
            {key: 14, value: 18}, {key: 15, value: 17},
            {key: 16, value: 16}, {key: 17, value: 18},
            {key: 18, value: 23}, {key: 19, value: 25} ]

chart = BarChart.new(dataset, width: 600, height: 250, padding: 1)
chart.add_data
