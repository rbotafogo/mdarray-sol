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

  def initialize
    
    path = $d3.geo.path(nil)
    @width = 500
    @height = 500
    
    svg = $d3.select("body")
            .append("svg")
            .attr("width", @width)
            .attr("height", @height)

    dir = File.expand_path(File.dirname(__FILE__))
    file_name = dir + "/us-states.json"
    file = File.read(file_name)
      
    us_states = JSON.parse(file)

    projection = $d3.geo.albersUsa(nil)
                   .translate([@width/2, @height/2])
                   .scale(500)
    
    path = $d3.geo.path(nil).projection(projection);    
    
    svg.selectAll("path")
      .data(us_states["features"])
      .enter(nil)
      .append("path")
      .attr("d", path)
      .style("fill", "steelblue")
    
  end
  
end

map = Map.new
