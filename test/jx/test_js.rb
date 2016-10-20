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


    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with numbers" do

      # Evaluate and return numbers
      assert_equal(1, B.eval("1"))
      assert_equal(1.345, B.eval("1.345"))
      assert_equal(10.345, B.eval("10.345"))
      assert_equal(1234567890987654321, B.eval("1234567890987654321"))

      assert_equal(true, (B.eval("1.35").is_a? Numeric))
      assert_equal(false, (B.eval("1.35").is_a? Array))

      # Store a number into a javascript object
      B.num = 1.234
      assert_equal(1.234, B.num)

    end

    #--------------------------------------------------------------------------------------
    # A javascript NumberObject will be converted to a Number.
    #--------------------------------------------------------------------------------------

    should "interface with number objects" do

      B.eval(<<-EOT)
        var n1 = new Number(2.35)
        var n2 = new Number(4.567)
      EOT

      assert_equal(2.35, B.n1)
      assert_equal(4.567, B.n2)

      assert_equal(true, (B.n2.is_a? Numeric))

      # use the 'new' constructor function on function 'Number', but at the end of all
      # this we are just setting num to a numeric.  
      num = B.Number.new(2.35)
      assert_equal(2.35, num)

      # num is a Number variable in the browser.
      B.num = B.Number.new(5.77345)
      assert_equal(5.77345, B.num)

      assert_equal(1.3345, B.push(1.3345))
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with boolean" do
      
      assert_equal(true, B.eval("true"))
      assert_equal(false, B.eval("false"))
      assert_equal(true, (B.eval("false").is_a? FalseClass))

      B.logt = true
      B.logf = false
      
      assert_equal(true, B.logt)
      assert_equal(false, B.logf)
      assert_equal(true, (B.logt.is_a? TrueClass))
      assert_equal(true, (B.logf.is_a? FalseClass))

      assert_equal(true, B.push(true))
      assert_equal(false, B.push(false))

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

      assert_equal(true, t)
      assert_equal(false, f)

      assert_equal(true, (t.is_a? TrueClass))
      assert_equal(false, t.nil?)

      assert_equal(true, B.t)
      assert_equal(false, B.f)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with strings" do

      B.str = "this is a string"
      assert_equal("this is a string", B.str)
      
      assert_equal(true, (B.str.is_a? String))

      # in order to evaluate a string, we need to double quote it, since the first quote
      # if for the javascript script
      str2 = B.eval("'this is a string'")
      assert_equal("this is a string", str2)

      assert_equal("this is a string", B.push("this is a string"))
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with string objects" do

      B.eval(<<-EOT)
        var str = new String("this is a string")
      EOT

      assert_equal("this is a string", B.str)
      assert_equal(true, (B.str.is_a? String))

      # str is a Ruby variable that points to data in the Browser
      str = B.push("this is a string")
      assert_equal("this is a string", str)

      # No need to use B.push for the string, since str2 is in the Browser, the string
      # is automatically converted, just checking that this actually works.
      B.str2 = B.push("this is also a string")
      assert_equal("this is also a string", B.str2)
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with functions" do

      # functions f and f2 are defined in the B namespace
      B.eval(<<-EOT)
        var f = function sum(x, y) { return x + y; };
        var f2 = function myFunc() { return 1; } 
      EOT

      # pulling function 'f' from the B namespace to the Ruby namespace
      f = B.pull("f")
      
      # To call a javascript function we need to call 'send' on the method with
      # the necessary parameters
      assert_equal(5, f.send(2, 3))

      # Access function through '.' Functions f and f2 are defined in the B namespace
      assert_equal(true, B.f2.function?)
      assert_equal(17, B.f(8, 9))
      
      # In order to call a function with no arguments in javascript we need to either
      # use the send method or call with nil as argument
      assert_equal(1, B.f2(nil))
      
      # Instead of using send, we can also use '[]' to call a javascript function.
      # This looks more like a function call
      assert_equal(1, B.f2[])

      # Define a function f3 in javascript.  This is  equivalent to the above
      # B.eval...
      B.f3 = B.function(<<-EOF)
        add(x, y) { return x + y; } 
      EOF
      
      # use standard notation for method call in the B namespace
      assert_equal(9, B.f3(4, 5))
      # or use '[]'
      assert_equal(9, B.f[4, 5])

      # We can also create a javascript function with the notation bellow. In
      # this case the function f4 lives in the Ruby namespace.
      f4 = B.function("(x, y) { return x + y; }")
      assert_equal(9, f4.send(4, 5))
      assert_equal(9, f4[4, 5])

      # in the Ruby namespace, standard '()' function call does not work
      assert_raise (NoMethodError) { f4(4,5) }

      # Just making sure that the creation of a new method does not affect
      # the previous one.
      f5 = B.function("(x, y) { return x - y; }")
      assert_equal(1, f5[5, 4])
      assert_equal(9, f4[5, 4])

      # Javascript function that receives a JSObject as argument
      f6 = B.function(<<-EOT)
        (x) { text = ""
                for (i = 0; i < x.length; i++) { 
                  text += x[i];
                }
              return text
            }
      EOT

      # add variable 'a' into the B namespace 
      # B.dup(:a, [1, 2, 3])
      B.a = B.dup([1, 2, 3])

      # call function f6 passign a JSObject
      assert_equal("123", f6[B.a])

      # use the B.dup function to duplicate a Ruby array to javascript
      assert_equal("123", f6[B.dup([1, 2, 3])])
      
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
      assert_equal("Saab", js_array.get(0))
      assert_equal("Volvo", js_array.get(1))
      assert_equal("BMW", js_array.get(2))

      a2 = B.cars
      assert_equal("Saab", a2.get(0))
      assert_equal("Volvo", a2.get(1))
      assert_equal("BMW", a2.get(2))
            
      assert_equal("Saab", a2[0])
      assert_equal("Volvo", a2[1])
      assert_equal("BMW", a2[2])
      
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

      EOF
      
      rcar = B.pull("car")
      
      assert_equal("Fiat", rcar.type)
      assert_equal(500, rcar.model)
      assert_equal("white", rcar.color)
      assert_equal(true, rcar.sold)

      # check the type of the object by calling B.typeof
      assert_equal("object", B.typeof(rcar))
      assert_equal(true, (rcar.type.is_a? String))
      assert_equal(true, (rcar.model.is_a? Numeric))
      assert_equal(true, (rcar.sold.is_a? TrueClass))
      assert_equal("function", B.typeof(rcar.print))

      # check the type of the object directly
      assert_equal("object", rcar.typeof)
      assert_equal("function", rcar.print.typeof)
      
      # call function on a native javascript object
      assert_equal(4, rcar.info.length)
      
      # call the print function by passing parameters to it
      assert_equal("Fiat_500", rcar.print("_", "500"))

      # Get the print function.  Change this so that rcar.print and rcar.print()
      # will both execute the fucntion and rcar.print(nil) returns the
      # function.  The latter case is less commom than the former.
      p_f = rcar.print
      
      # Execute the p_f function.  It should still be in the proper scope, i.e,
      # this still executes in the scope of object 'car', so 'type' should be
      # Fiat
      assert_equal("Fiat_500", p_f["_", "500"])

      # note that to call a method with no arguments
      assert_equal("no args given", rcar.no_args(nil))

      # access a deep structure
      assert_equal("Fiat", B.out.data.type)
      assert_equal("Fiat_500", B.out.data.print("_", "500"))
            
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "allow the use of javascript constructors" do

      Const = B.function(<<-EOT)
        (x, y) {
          this.number = new Number(x);
          this.value = y;
          this.str = arguments[2];
        }
      EOT

      const = Const.new(2, 3, "Hello Constructor")
      
      assert_equal(2, const.number)
      assert_equal(3, const.value)
      assert_equal("Hello Constructor", const.str)
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "properly return instanceof" do
      
      # The instanceof operator tests presence of constructor.prototype in object's
      # prototype chain.      

      # We are using here the javascript convention of writing constructor functions
      # with a capital letter.  In Ruby, this indicates a constant, which is not the
      # case here...
      # Defining constructors in the Browser 
      C = B.function("(){}")
      D = B.function("(){}")

      # ...; however, this looks like a new class creation in Ruby and it is
      # actually creating a new javascript object from the C function.
      o = C.new
      # true, because: Object.getPrototypeOf(o) === C.prototype      
      assert_equal(true, o.instanceof(C))

      # false, since D.prototype is not in the prototype chain of 'o'
      assert_equal(false, o.instanceof(D))

      # 'o' is an instance of a JSObject
      assert_equal(true, o.instanceof(B.Object))

      # C.prototype is also an instance of a JSObject
      assert_equal(true, C.prototype.instanceof(B.Object))

      C.prototype = B.dup({})
      o2 = C.new

      assert_equal(true, o2.instanceof(C))
      
      # false, because C.prototype is nowhere in o's prototype chain anymore      
      assert_equal(false, o.instanceof(C))

      #  use inheritance
      D.prototype = C.new
      o3 = D.new
      assert_equal(true, o3.instanceof(D))
      assert_equal(true, o3.instanceof(C))

      # simpleStr = B.eval("This is a simple string")
      myString  = B.String.new
      newStr    = B.String.new("String created with constructor")
      myDate    = B.Date.new;
      # myObj     = {}.jsdup
      # p myObj

      # returns false, checks the prototype chain, finds undefined      
      # p simpleStr.instanceof(B.String).v
      # returns true, despite an undefined prototype      
      # p myObj.instanceof(B.Object).v    
      assert_equal(true, myDate.instanceof(B.Date))
      assert_equal(true, myDate.instanceof(B.Object))
      assert_equal(false, myDate.instanceof(B.String))

      # ({})  instanceof Object;    // returns true, same case as above
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
      assert_equal("VW", rcar.type)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "copy Ruby objects to javascript" do

      # Create a Ruby Array
      cars = ["Saab", "Volvo", "BMW"]

      # Duplicate (copy) the Ruby Array as a javascript array
      # B.dup(:cars, cars)
      B.cars = B.dup(cars)

      assert_equal("Saab", B.cars[0])
      assert_equal("Volvo", B.cars[1])
      assert_equal("BMW", B.cars[2])

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
      # B.dup(:data, data)
      B.data = B.dup(data)
      
      assert_equal("2011-11-14T16:17:54Z", B.data[0].date)
      assert_equal(1, B.data[2].quantity)
      assert_equal(0, B.data[4].tip)

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

      # B.dup(:jscar, car)
      B.jscar = B.dup(car)
      jscar = B.jscar

      # Add a function to the jscar object.  Functions cannot be create in the
      # ruby hash above.
      jscar.print =
        B.function(<<-EOT)
          (x, y) { return x + y; } 
        EOT
      
      assert_equal("Fiat", jscar.type)
      assert_equal(500, jscar.model)
      assert_equal("white", jscar.color)
      assert_equal(true, jscar.sold)
      assert_equal(1, jscar.info[0])
      assert_equal(8, jscar.print(3, 5))      
      assert_equal(8, jscar.print[3, 5])

      # Call the method in two steps: first get the method then call the method
      # passing the arguments
      f = jscar.print
      assert_equal(8, f[3, 5])
      
    end

  end
  
end
