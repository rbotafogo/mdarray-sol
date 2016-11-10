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

dataset = [ 25, 7, 5, 26, 11, 8, 25, 14, 23, 19,
            14, 11, 22, 29, 11, 13, 12, 17, 18, 10,
            24, 18, 25, 9, 3 ]

body = $d3.select("body")
      

$d3.select("body").append("p").text("New paragraph!")

sleep(0.5)
$d3.select("body").selectAll("*").html("")
      
# 
body.selectAll("p")
  .data(dataset).enter(nil).append("p")
  .text { |d, i| "I'm index #{i} couting to #{d}" }
  .style("color") { |d, i| (d > 15)? "red" : "black" }


sleep(0.5)
$d3.select("body").selectAll("*").html("")
#=begin
#
body.selectAll('div')
  .data(dataset).enter(nil).append('div')
  .style('display', 'inline-block')
  .style('width', '20px')
  .style('background-color', 'teal')
  .style('margin-right', '2px')
  .style('height') { |d, i| (d * 5).to_s + "px" }
  .on('mouseout') { $d3.select(@this).style('background-color', 'teal') }
  .on('mouseover') { $d3.select(@this).style('background-color', 'black') }

sleep(0.5)
$d3.select("body").selectAll("*").html("")
#=end
=begin
# 
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
  .attr("x") { |d, i| i * (width / dataset.length + 1) +
               (width / dataset.length - bar_padding) / 2 }
  .attr("y") { |d, i| height - (d * 4) + 14 }
  .attr("font-family", "sans-serif")
  .attr("font-size", "11px")
  .attr("fill", "white")
  .attr("text-anchor", "middle")

# B.print_page
=end
      

