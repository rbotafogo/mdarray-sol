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

    should "test" do

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

      B.eval(<<-EOF)
        var car = {
          type: "Fiat",
          model: 500,
          color: "white",
          sold: true,
          info: [1, 2, 3, 4],
          print: function() {return this.type;}
        }

        var out = {
          data: car
        }
      EOF
      
      car = B.pull("car")

      assert_equal("Fiat", car.type)
      assert_equal(500, car.model)
      assert_equal("white", car.color)
      assert_equal(true, car.sold)

      assert_equal("object", B.typeof(car))
      assert_equal("string", B.typeof(car.type))
      assert_equal("number", B.typeof(car.model))
      assert_equal("boolean", B.typeof(car.sold))
      assert_equal("function", B.typeof(car.print))

      # Fix arguments
      p car.print.call("#{car.js}")
      p car.print.exec
                   
      assert_equal(true, B.instanceof(car, "object"))
      assert_equal(true, B.instanceof(car.info, "array"))
      assert_equal(true, B.instanceof(car.print, "function"))
      assert_equal(true, B.instanceof(car.print, "object"))
      assert_equal(false, B.instanceof(car, "array"))
      assert_equal(false, B.instanceof(car.info, "function"))
      assert_equal(false, B.instanceof(car.print, "array"))

      assert_equal(4, car.info.length)
      
      out = B.pull("out")
      assert_equal("Fiat", out.data.type)
      

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
