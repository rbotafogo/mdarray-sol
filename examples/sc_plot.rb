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

require_relative 'scatterplot/scatterplot'

class Example

  attr_reader :dataset

  def initialize(num_data_points)
    @num_data_points = num_data_points
  end
  
  def gen_random_data
    @dataset = []
    x_range = rand * 1000;
    y_range = rand * 1000;
    (1..@num_data_points).each do |i|
      @dataset << [(rand * x_range).floor, (rand * y_range).floor]
    end
    
  end
  
end

$d3.select("body")
  .append("p")
  .text("Click here to generate new dataset at any time!")

ex = Example.new(30)
ex.gen_random_data
splot = ScatterPlot.new(ex.dataset, width: 800, height: 450, padding: 50)
splot.plot

$d3.select("p")
  .on('click') {
  ex.gen_random_data
  splot.update(ex.dataset)
}
