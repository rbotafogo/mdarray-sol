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
=end      
    end
    
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
          print: function(a, b) {return this.type + a + b;}
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
                   
      assert_equal(true, B.instanceof(car, "object"))
      assert_equal(true, B.instanceof(car.info, "array"))
      assert_equal(true, B.instanceof(car.print, "function"))
      assert_equal(true, B.instanceof(car.print, "object"))
      assert_equal(false, B.instanceof(car, "array"))
      assert_equal(false, B.instanceof(car.info, "function"))
      assert_equal(false, B.instanceof(car.print, "array"))

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
      
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with d3" do

      $d3.select("body").append("div").text("hi there")

    end
=end    
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
