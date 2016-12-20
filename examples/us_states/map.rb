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

require 'json'

require_relative '../../config' if @platform == nil
require 'mdarray-sol'

class Map

  attr_reader :path
  attr_reader :svg
  attr_reader :us_states

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------
  
  def initialize(width, height)
    
    @width = width
    @height = height

    # Create svg for the map
    @svg = $d3.select("body")
             .append("svg")
             .attr("width", @width)
             .attr("height", @height)
    
  end
  
  #------------------------------------------------------------------------------------
  # Parses a file in GeoJson format and saves it as @us_states
  # @param filename [String] the name of the file to parse
  #------------------------------------------------------------------------------------

  def json(filename)
    
    dir = File.expand_path(File.dirname(__FILE__))
    file_name = dir + "/#{filename}"
    file = File.read(file_name)
    
    # parse the json file
    @us_states = JSON.parse(file)

  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def plot(projection)

    proj = projection
             .translate([@width/2, @height/2])
             .scale(500)
    @path = $d3.geo.path[].projection(proj);    
    
    @svg.selectAll("path")
      .data(@us_states["features"])
      .enter[]
      .append("path")
      .attr("d", @path)
      .style("fill", "steelblue")
    
  end
  
end

map = Map.new(500, 500)
map.json("us-states.json")
map.plot($d3.geo.albersUsa[])
