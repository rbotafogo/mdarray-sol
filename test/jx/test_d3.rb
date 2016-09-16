# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
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

require 'rubygems'
require "test/unit"
require 'shoulda'

require '../../config' if @platform == nil
require 'mdarray-sol'

class MDArraySolTest < Test::Unit::TestCase

  context "D3 environment" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with d3 and other javascript libraries" do

      # dataset = [ 5, 10, 15, 20, 25 ]
#=begin
      dataset = [ 25, 7, 5, 26, 11, 8, 25, 14, 23, 19,
                  14, 11, 22, 29, 11, 13, 12, 17, 18, 10,
                  24, 18, 25, 9, 3 ]
#=end      
      body = $d3.select("body")
      
=begin
      $d3.select("body").append("p").text("New paragraph!");

      sleep(0.5)
      $d3.select("body").selectAll("p").remove
=end
      
=begin      
      body.selectAll("p")
        .data(dataset).enter(nil).append("p")
        .text { |d, i| "I'm index #{i} couting to #{d}" }
        .style("color") { |d, i| (d > 15)? "red" : "black" }

=end

=begin      
      B.eval(<<-EOT)

      var dataset = [ 5, 10, 15, 20, 25 ];

      d3.select("body").selectAll("div")
        .data(dataset).enter().append("div")
        .style('display', 'inline-block')
        .style('width', '20px')
        .style('background-color', 'teal')
        .style('height', function(d) { console.log(d); return d + "px"; })
        .on('mouseover', function() {
			d3.select(this)
	 		.style('background-color','black')
	 	})
	.on('mouseout', function () {
			d3.select(this)
			.style('background-color', function (d) { return d.backgroundColor; })
		})

      EOT
=end
      
=begin
      body.selectAll('div')
        .data(dataset).enter(nil).append('div')
        .style('display', 'inline-block')
        .style('width', '20px')
        .style('background-color', 'teal')
        .style('margin-right', '2px')
        .style('height') { |d, i| (d * 5).to_s + "px" }
=end

=begin      
      width = 500
      height = 50
      
      svg = $d3.select("body")
            .append("svg")
            .attr("width", width)
            .attr("height", height)
      
      circles = svg.selectAll("circle")
                .data(dataset)
                .enter(nil)
                .append("circle")
      
      circles.attr("cx") { |d, i| (i * 50) + 25 }
        .attr("cy", height/2)
        .attr("r") { |d, i| d }
        .attr("fill", "yellow")
        .attr("stroke", "orange")
        .attr("stroke-width") { |d, i| d/2 }
=end
      
      width = 500
      height = 100
      bar_padding = 1

      svg2 = $d3.select("body")
             .append("svg")
             .attr("width", width)
             .attr("height", height)

      svg2.selectAll("rect")
        .data(dataset)
        .enter(nil)
        .append("rect")
        .attr("x") { |d, i| i * (width / dataset.length + 1) }
        .attr("y") { |d, i| height - (d * 4) }
        .attr("width", width / dataset.length - bar_padding) 
        .attr("height") { |d, i| (d * 4)}
        .attr("fill") { |d, i| "rgb(0, 0, #{(d * 10).to_i})" }

      svg2.selectAll("text")
        .data(dataset)
        .enter(nil)
        .append("text")
        .text { |d, i| d }
        .attr("x") { |d, i| i * (width / dataset.length) +
                     (width / dataset.length - bar_padding) / 2 }
        .attr("y") { |d, i| height - (d * 4) + 14 }
        .attr("font-family", "sans-serif")
        .attr("font-size", "11px")
        .attr("fill", "white")
        .attr("text-anchor", "middle")

      # B.print_page
      
    end
    
  end

end

