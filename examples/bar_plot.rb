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

require_relative 'bar_chart/bar_chart'

class Example

  attr_reader :dataset
  attr_reader :x_range

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------
  
  def initialize(num_data_points)
    @num_data_points = num_data_points
    @x_range = rand * 200;
  end
  
  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def gen_random_data
    @dataset = []
    (1..@num_data_points).each do |i|
      @dataset << {key: i, value: (rand * @x_range).floor}
    end
    
  end

  #--------------------------------------------------------------------------------------
  #
  #--------------------------------------------------------------------------------------

  def gen_bar
    @num_data_points += 1
    @dataset << {key: (@dataset[-1][:key] + 1), value: (rand * @x_range).floor}
  end
  
end

$d3.select("body")
  .append("p")
  .attr("class", "new_data")
  .text("Click here to generate new dataset at any time!")

$d3.select("body")
  .append("p")
  .attr("class", "new_bar")
  .text("Ckick here to add a new bar")

$d3.select("body")
  .append("p")
  .attr("class", "del_data")
  .text("Click here to remove a bar")


ex = Example.new(20)
ex.gen_random_data

bplot = BarChart.new(ex.dataset, width: 600, height: 250, padding: 50)
bplot.plot

$d3.select(".new_data").on('click') {
  ex.gen_random_data
  bplot.update(ex.dataset)
}

$d3.select(".new_bar").on('click') {
  ex.gen_bar
  bplot.add_bar
}

$d3.select(".del_data").on('click') {
  bplot.remove_bar
}

