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
require 'json'

class SciComTest < Test::Unit::TestCase

  context "B environment" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with simple objects" do
      
      assert_equal(1, B.eval("1"))
      assert_equal(true, B.eval("true"))
      assert_equal(false, B.eval("false"))
      assert_equal(nil, B.eval("null"))
      assert_equal("this is a string", B.eval("'this is a string'"))
      assert_equal(10.345, B.eval("10.345"))
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "obtain javascript objects" do

      struct = {:type => "Fiat", :model => "500"}
      p struct.to_json
      
      B.eval(<<-EOF)
        var car = {
          type: "Fiat",
          model: "500",
          color: "white",
          print: function(val1, val2) {return this.type + val1 + val2;}
        }
      EOF
      
      car = B.pull("car")
      p car.print(1, 2)
      assert_equal("Fiat", car.type)
      assert_equal("500", car.model)
      assert_equal("white", car.color)

    end
    
  end

end


=begin
js = Sol.js
js.eval("d3.select(\"body\").append(\"div\").text(\"hi there\");")

js.eval(<<-EOF)
  d3.select("body").append("div").text("hi there again!");
  var numberFloat = 123.45678;
  d3.select("body").append("div").text(numberFloat.$round(2));
  var myVar = Opal.Variable.$new();
  d3.select("body").append("div").text(myVar.$hello());
EOF
=end
