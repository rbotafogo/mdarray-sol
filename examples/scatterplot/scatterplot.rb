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

##########################################################################################
# This code is based on the code presented on "Interactive Data Visualization for the Web"
# by Scott Muray
##########################################################################################

require_relative '../../config' if @platform == nil
require 'mdarray-sol'

require_relative '../util/linear_scale'
require_relative 'axes'

#=========================================================================================
# Implements a ScatterPlot using d3.js
#=========================================================================================

class ScatterPlot

  attr_reader :dataset
  attr_reader :width
  attr_reader :height
  attr_reader :svg
  attr_reader :padding
  attr_reader :x_scale
  attr_reader :y_scale
  attr_reader :axes

  #--------------------------------------------------------------------------------------
  # Initialize the scatterplot and create the main svg for the plot with the given
  # width and height and padding
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

    @svg = $d3.select("body")
           .append("svg")
           .attr("width", @width)
           .attr("height", @height)
  end

  #--------------------------------------------------------------------------------------
  # @param x_scale [LinearScale] the x scale for the data, this is a Scale object that
  # encapsulates the scale function from d3.  x_scale defauts to the scatterplot x scale.
  # Usually this will always be the case, but we need to set it since x_scale is used
  # inside a block
  # @param y_scale [LinearScale] the y scale for the data, this is a Scale object that
  # encapsulates the scale function from d3. Same observation as above to y_scale.
  #--------------------------------------------------------------------------------------

  def add_data(x_scale = @x_scale, y_scale = @y_scale)
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
  # Defines the style for the labels in the plot.  Method style returns a Proc with the
  # groups attributes
  #--------------------------------------------------------------------------------------

  def style
    Proc.new do |g|
      g.attr("font-family", "sans-serif")
      g.attr("font-size", "10px")
      g.attr("fill", "gray")
    end
  end

  #--------------------------------------------------------------------------------------
  # @param x_scale [LinearScale] the x scale for the data, this is a Scale object that
  # encapsulates the scale function from d3.  x_scale defauts to the scatterplot x scale.
  # Usually this will always be the case, but we need to set it since x_scale is used
  # inside a block
  # @param y_scale [LinearScale] the y scale for the data, this is a Scale object that
  # encapsulates the scale function from d3. Same observation as above to y_scale.
  #--------------------------------------------------------------------------------------

  def add_labels(x_scale = @x_scale, y_scale = @y_scale)
    @svg.selectAll("text")
      .data(@dataset)
      .enter(nil)
      .append("text")
      .call(&style)
      .text { |d, i| "(#{d[0].to_i}, #{d[1].to_i})" }
      .attr("x") { |d, i| x_scale[d[0]] }
      .attr("y") { |d, i| y_scale[d[1]] }
  end

  #--------------------------------------------------------------------------------------
  # Plots the scatterplot
  #--------------------------------------------------------------------------------------

  def plot
    
    x_min, x_max = @dataset.minmax_by { |d| d[0] }
    y_min, y_max = @dataset.minmax_by { |d| d[1] }

    # Creates a new x and y scale and the axes for the plot
    @x_scale = LinearScale.new([0, x_max[0]], [@padding, @width - @padding * 2])
    @y_scale = LinearScale.new([0, y_max[1]], [@height - @padding, @padding])
    @axes = Axes.new(self, @x_scale.scale, @y_scale.scale)

    add_data
    add_labels
    # add x and y axes to the plot
    @axes.plot
    
  end

  #--------------------------------------------------------------------------------------
  # This method updates and plots all the points in the scatter plot. Note that we use
  # transition, duration and each methods to animate the update process.
  #
  # @param x_scale [LinearScale] the x scale for the updated dataset. Uses @x_scale as
  # default since x_scale is used inside a block.  @x_scale should have already being
  # updated
  # @param y_scale [LinearScale] the y scale for the updated dataset. Uses @y_scale as
  # default since y_scale is used inside a block.  @y_scale should have already being
  # updated
  #--------------------------------------------------------------------------------------

  def update_points(x_scale = @x_scale, y_scale = @y_scale)
    @svg.selectAll("circle")
      .data(@dataset)
      .transition(nil)
      .duration(2000)
      .each("start") { $d3.select(@this)
                         .attr("fill", "magenta")
                         .attr("r", 3) }
      .attr("cx") { |d, i| x_scale[d[0]] }
      .attr("cy") { |d, i| y_scale[d[1]] }
      .each("end") { $d3.select(@this)
                       .transition(nil)
                       .duration(1000)
                       .attr("fill", "black")
                       .attr("r", 2) }

  end

  #--------------------------------------------------------------------------------------
  # This method updates and plots all the labels in the scatter plot.
  #
  # @param x_scale [Scale] the x scale for the updated dataset. Uses @x_scale as default
  # since x_scale is used inside a block.  @x_scale should have already being updated
  # @param y_scale [Scale] the y scale for the updated dataset. Uses @y_scale as default
  # since y_scale is used inside a block.  @y_scale should have already being updated
  #--------------------------------------------------------------------------------------

  def update_labels(x_scale = @x_scale, y_scale = @y_scale)
    
    @svg.selectAll("text")
      .data(@dataset)
      .text { |d, i| "(#{d[0].to_i}, #{d[1].to_i})" }
      .attr("x") { |d, i| x_scale[d[0]] }
      .attr("y") { |d, i| y_scale[d[1]] }
    
  end
  
  #--------------------------------------------------------------------------------------
  # This method is called when the dataset is updated.  This will trigger the update of
  # points, labels and axes
  #
  # @param dataset [Array] a new dataset with the same number of elements as the previous
  # dataset
  #--------------------------------------------------------------------------------------

  def update(dataset)

    @dataset = dataset

    # correct the x and y scale to the new dataset
    x_min, x_max = @dataset.minmax_by { |d| d[0] }
    y_min, y_max = @dataset.minmax_by { |d| d[1] }

    # fix the scale to the new dataset
    @x_scale.update([0, x_max[0]], [@padding, @width - @padding * 2])
    @y_scale.update([0, y_max[1]], [@height - @padding, @padding])

    # update the points, axes and labels
    update_points
    @axes.update(@x_scale.scale, @y_scale.scale)
    update_labels
    
  end

end

