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


    should "callback a jspacked Ruby object" do

      # create an array of data in Ruby
      array = [1, 2, 3, 4]

      # Pack the array and assign it to an R variable.
      B.ruby_array = B.jspack(array)
      assert_equal(4, B.ruby_array.send("length").v)

      # Check that the array is available in the Browser
      B.eval(<<-EOT)
        console.log(ruby_array.send("length"))
      EOT

      # add a new element to the array
      B.ruby_array.send("<<", 5)
      assert_equal(2, B.ruby_array.send("[]", 1).v)
      assert_equal(5, B.ruby_array.send(:[], 4).v)
      # check that both the Ruby array and the Browser array use the same
      # backing store, i.e., array should now have the element 5:
      assert_equal(5, array[4])

      # Check that we can still access the ruby_array from within javascript
      B.eval(<<-EOT)
        console.log(ruby_array.send("length"))
        console.log(ruby_array.send("[]", 4))
      EOT

      num = B.Number.new("1")
      assert_equal(nil, num.send(:length))
      
      # Set a Ruby variable to point to an object in the Browser
      jsarray = B.jspack([10, 20, 30, 40])
      jsarray.send("<<", 10)

      # make jsarray available to javascript
      B.data = jsarray
      B.eval(<<-EOT)
         console.log("Expected value is 10 and returned is: " + data.send("[]", 4))
      EOT

      assert_equal(40, jsarray.send(:[], 3).v)

      # Let's do method chainning
      jsarray.send(:<<, 100).send(:<<, 200).send(:to_s).v

      # send a block to a Ruby method from javascript
      B.eval(<<-EOT)
         data.send("map", "{ |x| p x }")
      EOT

      jsarray.send("map", "{ |x| p x }")
      jsarray.send("map") { |x| p x }
      
=begin

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
=end
      
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
=begin
    should "allow Ruby arrays to be used in js without copying" do

      pa = B.proxy([1, 2, 3, 4])
      p pa
      B.eval("#{pa}[1] = 'Hello'")
      
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
