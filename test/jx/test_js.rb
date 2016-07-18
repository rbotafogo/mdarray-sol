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

  context "B environment" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end
    
#=begin    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with numbers" do

      # Evaluate and return numbers
      assert_equal(1, B.eval("1").byte)
      assert_equal(1.345, B.eval("1.345").double)
      assert_equal(10.345000267028809, B.eval("10.345").float)
      assert_equal(1, B.eval("1").int)
      assert_equal(1234567890987654400, B.eval("1234567890987654321").long)
      assert_equal(1.35, B.eval("1.35").value)
      
      assert_equal(true, B.eval("1.35").number?)
      assert_equal(false, B.eval("1.35").array?)

      # Store a number into a javascript object
      B.num = 1.234
      assert_equal(1.234, B.num.double)
      
    end

    #--------------------------------------------------------------------------------------
    # A javascript NumberObject will be converted to a Number.
    #--------------------------------------------------------------------------------------

    should "interface with number objects" do

      B.eval(<<-EOT)
        var n1 = new Number(2.35)
        var n2 = new Number(4.567)
      EOT

      assert_equal(2.35, B.n1.v)
      assert_equal(4.567, B.n2.v)
      
      assert_equal(true, B.n2.number?)
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with boolean" do
      
      assert_equal(true, B.eval("true").value)
      assert_equal(false, B.eval("false").value)
      assert_equal(true, B.eval("false").boolean?)

      B.logt = true
      B.logf = false
      
      assert_equal(true, B.logt.v)
      assert_equal(false, B.logf.v)

      assert_equal(true, B.logt.boolean?)
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with boolean objects" do

      B.eval(<<-EOT)
        var t = new Boolean(true)
        var f = new Boolean(false)
      EOT

      t = B.pull("t")
      f = B.pull("f")

      assert_equal(true, t.value)
      assert_equal(false, f.value)

      assert_equal(true, t.boolean?)
      assert_equal(false, t.nil?)

      assert_equal(true, B.t.v)
      assert_equal(false, B.f.v)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with strings" do

      B.str = "this is a string"
      assert_equal("this is a string", B.str.v)
      
      assert_equal(true, B.str.string?)
      
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with string objects" do

      B.eval(<<-EOT)
        var str = new String("this is a string")
      EOT

      assert_equal("this is a string", B.str.v)
      
      assert_equal(true, B.str.string?)
      
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with functions" do

      B.eval(<<-EOT)
        var f = function sum(x, y) { return x + y; };
        var f2 = function myFunc() { return 1; } 
      EOT

      f = B.pull("f")
      # To call a javascript function we wee to call 'send' on the method with
      # the necessary parameters
      assert_equal(5, f.send(2, 3).value)

      # Access function through '.' 
      assert_equal(true, B.f2.function?)
      assert_equal(17, B.f(8, 9).value)
      
      # In order to call a function with no arguments in javascript we need to either
      # use the send method or call with nil as argument
      assert_equal(1, B.f2(nil).v)
      # Instead of using send, we can also use '[]' to call a javascript function.
      # This looks more like a function call
      assert_equal(1, B.f2[].v)

      # Define a function f3 in javascript.  This is  equivalent to the above
      # B.eval...
      B.function(:f3, <<-EOF)
        add(x, y) { return x + y; } 
      EOF
      
      assert_equal(9, B.f3(4, 5).v)

      # We can also create a javascript function with this notation bellow
      f4 = B.function("(x, y) { return x + y; }")
      assert_equal(9, f4.send(4, 5).v)
      assert_equal(9, f4[4, 5].v)

      f5 = B.function("(x, y) { return x - y; }")
      # Just making sure that the creation of a new method does not affect
      # the previous one.
      assert_equal(1, f5[5, 4].v)
      assert_equal(9, f4[5, 4].v)

      B.dup(:a, [1, 2, 3])

      # Javascript function that receives a JSObject as argument
      f6 = B.function(<<-EOT)
        (x) { text = ""
                for (i = 0; i < x.length; i++) { 
                  text += x[i];
                }
              return text
            }
      EOT

      assert_equal("123", f6[B.a].v)
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with js arrays" do
      
      # cars is a js array
      B.eval(<<-EOT)
        var cars = ["Saab", "Volvo", "BMW"];
      EOT

      js_array = B.pull("cars")
      assert_equal("Saab", js_array.get(0).value)
      assert_equal("Volvo", js_array.get(1).value)
      assert_equal("BMW", js_array.get(2).value)

      a2 = B.cars
      assert_equal("Saab", a2.get(0).v)
      assert_equal("Volvo", a2.get(1).v)
      assert_equal("BMW", a2.get(2).v)
            
      assert_equal("Saab", a2[0].v)
      assert_equal("Volvo", a2[1].v)
      assert_equal("BMW", a2[2].v)
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "access javascript objects" do

      B.eval(<<-EOF)
        var car = {
          type: "Fiat",
          model: 500,
          color: "white",
          sold: true,
          info: [1, 2, 3, 4],
          print: function(a, b) {return this.type + a + b;},
          no_args: function() {return "no args given";}
        }

        var out = {
          data: car
        }

        console.log(car.print("_", "500"));
      EOF
      
      rcar = B.pull("car")
      
      assert_equal("Fiat", rcar.type.v)
      assert_equal(500, rcar.model.v)
      assert_equal("white", rcar.color.v)
      assert_equal(true, rcar.sold.v)

      # check the type of the object by calling B.typeof
      assert_equal("object", B.typeof(rcar).v)
      assert_equal("string", B.typeof(rcar.type).v)
      assert_equal("number", B.typeof(rcar.model).v)
      assert_equal("boolean", B.typeof(rcar.sold).v)
      assert_equal("function", B.typeof(rcar.print).v)

      # check the type of the object directly
      assert_equal("object", rcar.typeof.v)
      assert_equal("string", rcar.type.typeof.v)
      assert_equal("number", rcar.model.typeof.v)
      assert_equal("boolean", rcar.sold.typeof.v)
      assert_equal("function", rcar.print.typeof.v)
      
      # call function on a native javascript object
      assert_equal(4, rcar.info.length)
      
      # call the print function by passing parameters to it
      assert_equal("Fiat_500", rcar.print("_", "500").v)
      
      # note that to call a method with no arguments we need to provide nil as
      # argument.  If we don't give nil as argument we will get the function
      # in return.
      assert_equal("no args given", rcar.no_args(nil).v)

      # access a deep structure
      assert_equal("Fiat", B.out.data.type.v)
      assert_equal("Fiat_500", B.out.data.print("_", "500").v)
            
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "properly return instanceof" do

      C = B.function("(){}")
      D = B.function("(){}")

      o = B.C.new
      
      JSObject =  B.eval("Object")
      p rcar.instanceof(JSObject).v

    end
      
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "add data to a javascript object" do

      B.eval(<<-EOT)
        var car = {}
      EOT

      rcar = B.pull("car")
      rcar.type = "VW"
      assert_equal("VW", rcar.type.v)

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "copy Ruby objects to javascript" do

      # Create a Ruby Array
      cars = ["Saab", "Volvo", "BMW"]

      # Duplicate (copy) the Ruby Array as a javascript array
      B.dup(:cars, cars)

      assert_equal("Saab", B.cars[0].v)
      assert_equal("Volvo", B.cars[1].v)
      assert_equal("BMW", B.cars[2].v)

      # A more complex array
      data = [
        {date: "2011-11-14T16:17:54Z", quantity: 2, total: 190, tip: 100, type: "tab"},
        {date: "2011-11-14T16:20:19Z", quantity: 2, total: 190, tip: 100, type: "tab"},
        {date: "2011-11-14T16:28:54Z", quantity: 1, total: 300, tip: 200, type: "visa"},
        {date: "2011-11-14T16:30:43Z", quantity: 2, total: 90, tip: 0, type: "tab"},
        {date: "2011-11-14T16:48:46Z", quantity: 2, total: 90, tip: 0, type: "tab"},
        {date: "2011-11-14T16:53:41Z", quantity: 2, total: 90, tip: 0, type: "tab"},
        {date: "2011-11-14T16:54:06Z", quantity: 1, total: 100, tip: 0, type: "cash"},
        {date: "2011-11-14T16:58:03Z", quantity: 2, total: 90, tip: 0, type: "tab"},
        {date: "2011-11-14T17:07:21Z", quantity: 2, total: 90, tip: 0, type: "tab"},
        {date: "2011-11-14T17:22:59Z", quantity: 2, total: 90, tip: 0, type: "tab"},
        {date: "2011-11-14T17:25:45Z", quantity: 2, total: 200, tip: 0, type: "cash"},
        {date: "2011-11-14T17:29:52Z", quantity: 1, total: 200, tip: 100, type: "visa"}
      ]

      # Copy the data array to "data" element in javascript
      B.dup(:data, data)
      
      assert_equal("2011-11-14T16:17:54Z", B.data[0].date.v)
      assert_equal(1, B.data[2].quantity.v)
      assert_equal(0, B.data[4].tip.v)

    end
    


    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "Create javascript objects from a Ruby hash" do

      car = {
        type: "Fiat",
        model: 500,
        color: "white",
        sold: true,
        info: [1, 2, 3, 4]
      }

      B.dup(:jscar, car)
      jscar = B.jscar

      # Add a function to the jscar object.  Functions cannot be create in the
      # ruby hash above.
      jscar.print =
        B.function(<<-EOT)
          (x, y) { return x + y; } 
        EOT
      
      assert_equal("Fiat", jscar.type.v)
      assert_equal(500, jscar.model.v)
      assert_equal("white", jscar.color.v)
      assert_equal(true, jscar.sold.v)
      assert_equal(1, jscar.info[0].v)
      assert_equal(8, jscar.print[3, 5].v)
      
    end
#=end    
  end
  
end

=begin            
      assert_equal(true, B.instanceof(car, B.Object))
      assert_equal(true, B.instanceof(car.info, "array"))
      assert_equal(true, B.instanceof(car.print, "function"))
      assert_equal(true, B.instanceof(car.print, "object"))
      assert_equal(false, B.instanceof(car, "array"))
      assert_equal(false, B.instanceof(car.info, "function"))
      assert_equal(false, B.instanceof(car.print, "array"))
=end
