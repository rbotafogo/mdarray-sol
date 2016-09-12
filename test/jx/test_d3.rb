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
      
=begin
      B.eval(<<-EOT)
        dataset = [ 5, 10, 15, 20, 25 ]

        d3.select("body").selectAll("p")
          .data(dataset)
          .enter()
          .append("p")
          .text("New paragraph!");
      EOT
=end

      dataset = [ 5, 10, 15, 20, 25 ]
      
=begin
      $d3.select("body").selectAll("p")
        .data(dataset).enter(nil).append("p")
        .text("New paragraph!")

      
      $d3.select("body").selectAll("p")
        .data(dataset).enter(nil).append("p")
        .text(B.function("(d) { return d; }"))
=end

      block = Sol::Callback.new do |*args|
        (args[0] > 15)? "red" : "black"
      end
      
      # block = Sol::Callback.new { |x| x }
      B.block = block
      
      B.eval(<<-EOT)
        function bk(x) { return block.run("call", x); }
      EOT
      
      $d3.select("body").selectAll("p")
        .data(dataset).enter(nil).append("p")
        .text("hello").style("color", B.bk)
      
    end
    
  end

end
