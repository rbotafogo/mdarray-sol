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

    should "interface with arrays" do
      # Array
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

    should "interface with functions" do

      B.eval(<<-EOT)
        var f = function sum(x, y) { return x + y; };
        var f2 = function myFunc() { return 1; } 
      EOT

      f = B.pull("f")
      assert_equal(5, f.send(2, 3).value)

      # Access function through '.' 
      assert_equal(true, B.f2.function?)
      assert_equal(17, B.f(8, 9).value)
      
      # In order to call a function with no arguments in javascript we need to either
      # use the send method or call with nil as argument
      assert_equal(1, B.f2(nil).v)

      # Define a function f3 in javascript.  This is  equivalent to the above
      # B.eval...
      B.function(:f3, <<-EOF)
        add(x, y) { return x + y; } 
      EOF
      
      assert_equal(9, B.f3(4, 5).v)

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
          print: function(a, b) {return this.type + a + b;}
        }

        var out = {
          data: car
        }
      EOF
      
      car = B.pull("car")
      
      assert_equal("Fiat", car.type.v)
      assert_equal(500, car.model.v)
      assert_equal("white", car.color.v)
      assert_equal(true, car.sold.v)

      assert_equal("object", B.typeof(car).v)
      assert_equal("string", B.typeof(car.type).v)
      assert_equal("number", B.typeof(car.model).v)
      assert_equal("boolean", B.typeof(car.sold).v)
      assert_equal("function", B.typeof(car.print).v)

=begin            
      assert_equal(true, B.instanceof(car, B.Object))
      assert_equal(true, B.instanceof(car.info, "array"))
      assert_equal(true, B.instanceof(car.print, "function"))
      assert_equal(true, B.instanceof(car.print, "object"))
      assert_equal(false, B.instanceof(car, "array"))
      assert_equal(false, B.instanceof(car.info, "function"))
      assert_equal(false, B.instanceof(car.print, "array"))
=end
      
=begin                   
      assert_equal(4, car.info.length)

      # call the print function by passing parameters to it
      assert_equal("Fiat_500", car.print("_", "500"))
      
      # call the print function.  Note that 'call' requires the environment (variable)
      # for binding the call, while 'send' does not require binding, as it is
      # already bound the the original environment
      assert_equal("FiatType: 500", car.print.call(car, "Type: ", 500))
      # Here car.print.send("_", "500") is identical do car.print("_", "500")
      assert_equal("Fiat_500", car.print.send("_", "500"))

      # However, doing
      func = car.print
      # we get an execption if we do
      assert_raise ( NoMethodError ) { func("_", "500") }
      # since 'func' is not a method, but a javascript method wrapped in a jsfunction
      # object.  For this to work we need 'send' or 'call':
      assert_equal("Fiat_500", func.send("_", "500"))

      out = B.pull("out")
      assert_equal("Fiat", out.data.type)
=end      
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

=begin    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "interface with Java objects" do
      
      dbl = MDArray.double([2, 2], [1, 2, 3, 4])
      B.assign("dbl", dbl.nc_array)
      B.eval(<<-EOT)
        var dbl2 = dbl.toString();
      EOT

      # jclass = java.lang.Class.forName("ucar.ma2.ArrayDouble$D2")
      # p jclass
      
      p B.eval("dbl.get(0,0)").double
      p B.eval("dbl.get(1,1)").double
      # p B.eval("dbl2").double
      
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "callback Ruby classes" do

      # class Log < Java::RbMdarray_sol.Callback
      class Log
        include Java::RbMdarray_sol.RubyCallbackInterface
        
        def run(*args)
          message = args[0]
        end
        
      end

      class RBObject
        include Java::RbMdarray_sol.RubyCallbackInterface

        attr_reader :rbobject
        
        def initialize(rbobject)
          @rbobject = rbobject
          @jarray = [].to_java
        end

        def run(args)
          args = args.to_a
          raise args.to_s
          @rbobject.send(message, *args)
        end

        def jsarray(args)
          return @jarray
        end
          
      end

      rb = RBObject.new(1)
      p rb.jsarray(1)

      mdarray = RBObject.new(MDArray.double([2, 2], [1, 2, 3, 4]))
      # p mdarray.run(["get", [1, 1]])
      
      B.assign("mdarray", mdarray)
      B.args = ["get", [1, 1]]
      # B.eval("var val = mdarray.run(args)")
      B.eval(<<-EOT)
        var args = mdarray.jsarray(1)
        args.append(1)
        var val = mdarray.run(args)
      EOT
      p B.val
=end      
=begin      
      log = Log.new
      B.assign("log", log)
      B.eval("var mes = log.run('this is a message to log')")
      p B.mes
      
      cb = Java::RbMdarray_sol.Callback.new
      
      B.assign("cb", cb)
      B.eval("var str = cb.run('hello world')")
      p B.str

      B.jarray = [1, 2]
      
      B.eval("var obj = cb.run(jarray)")
      p B.obj

    end
=end
    
=begin
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "access and retrieve javascript objects and functions" do

      B.js_obj = "This is a string"
      js_obj = B.pull("js_obj")
      assert_equal("This is a string", js_obj)
      assert_equal("This is a string", B.js_obj)

      B.eval(<<-EOF)
        var func1 = function() {return 1;};
        var func2 = function(par1) {return par1;};
        var func3 = function(par1, par2) {return par1 + " " + par2;};
      EOF

      assert_equal(1, B.func1)
      assert_equal("hello", B.func2("hello"))
      assert_equal("hello world", B.func3("hello", "world"))
      
    end
=end
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
=begin
    should "callback rpacked classes Array and Hash" do

      # create an array of data in Ruby
      array = [1, 2, 3]

      # Pack the array and assign it to an R variable.  Remember that ruby__array, becomes
      # ruby.array inside the R script
      R.ruby__array = R.rpack(array)

      # note that this calls Ruby method 'length' on the array and not R length function.
      R.eval("val <- ruby.array$run('length')")
      assert_equal(3, R.val.gz)

      # Let's use a more interesting array method '<<'.  This method adds elements to the
      # end of the array.  

      R.eval(<<-EOT)
        print(typeof(ruby.array))
        ruby.array$run('<<', 4)
        ruby.array$run('<<', 5)
      EOT
      assert_equal(4, array[3])
      assert_equal(5, array[4])

      # Although the concept of chainning is foreign to R, it does apply to packed
      # classes
      R.eval(<<-EOT)
        ruby.array$run('<<', 6)$run('<<', 7)$run('<<', 8)$run('<<', 9)
      EOT
      assert_equal(9, array[8])
      
      # Let's try another method... remove a given element from the array
      R.eval(<<-EOT)
        ruby.array$run('delete', 4)
      EOT
      assert_equal(5, array[3])

      # We can also acess any array element inside the R script, but note that we have
      # to use Ruby indexing, i.e., the first element of the array is index 0
      R.eval(<<-EOT)
        print(ruby.array$run('[]', 0))
        print(ruby.array$run('[]', 2))
        print(ruby.array$run('[]', 4))
        print(ruby.array$run('[]', 6))
      EOT

      # Try the same with a hash
      hh = {"a" => 1, "b" =>2}

      # Pack the hash and store it in R variable r.hash
      R.r__hash = R.rpack(hh, scope: :external)

      # Retrieve the value of a key
      R.eval(<<-EOT)
        h1 <- r.hash$run('[]', "a")
        h2 <- r.hash$run('[]', "b")
      EOT
      assert_equal(1, R.h1.gz)
      assert_equal(2, R.h2.gz)

      # Add values to the hash
      R.eval(<<-EOT)
        h1 <- r.hash$run('[]=', "c", 3)
        h2 <- r.hash$run('[]=', "d", 4)
      EOT
      assert_equal(3, hh["c"])
      assert_equal(4, hh["d"])
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "access Ruby objects from JavaScript" do

      B.eval(<<-EOF)
        var car = { }
      EOF

      array = JsArray.new([1, 2, 3, 4])
      B.assign("car", array)
      car = B.pull("car")
      
      f1 = B.eval("car")
      p "data set"
      f2 = B.eval("car.external.notset")
      p f2

      p B.eval("car.external.send('[]', 0)")
      p "message send"
      
      # array = B.eval("car.external")
      # p array

    end
=end        
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
=begin

    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with d3 and other javascript libraries" do

      $d3.select("body").append("div").text("hi there")

    end
=end
  
  end

end


=begin
      B.eval(Opal.compile(<<-EOT)
        class Tt
          def tt(x, y)
             x + y
          end
        end
      EOT
            )

      p B.Opal.Tt.__new(nil)

      ret = B.eval(<<-EOT)
        Opal.Tt.$new().$tt(3, 4)
      EOT

      p ret.v


      B.eval(<<-EOT)
      var name;
      for (name in Opal.Tt) {
        if (Opal.Tt.hasOwnProperty(name)) {
          console.log(name)
       }
       else {
          console.log(name)
       }
      }
      EOT
=end
