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


    should "callback a jspacked Ruby Array" do

      # create an array of data in Ruby
      array = [1, 2, 3, 4]

      # Pack the array and assign it to an R variable.
      B.ruby_array = B.jspack(array)
      assert_equal(4, B.ruby_array.run("length").v)

      # Check that the array is available in the Browser
      B.eval(<<-EOT)
        console.log(ruby_array.run("length"))
      EOT

      # add a new element to the array
      B.ruby_array.run("<<", 5)
      assert_equal(2, B.ruby_array.run("[]", 1).v)
      assert_equal(5, B.ruby_array.run(:[], 4).v)
      # check that both the Ruby array and the Browser array use the same
      # backing store, i.e., array should now have the element 5:
      assert_equal(5, array[4])

      # Check that we can still access the ruby_array from within javascript
      B.eval(<<-EOT)
        console.log(ruby_array.run("length"))
        console.log(ruby_array.run("[]", 4))
      EOT

      num = B.Number.new("1")
      assert_equal(true, num.run(:length).undefined?)
      
      # Set a Ruby variable to point to an object in the Browser
      jsarray = B.jspack([10, 20, 30, 40])
      jsarray.run("<<", 10)

      # make jsarray available to javascript
      B.data = jsarray
      B.eval(<<-EOT)
         console.log("Expected value is 10 and returned is: " + data.run("[]", 4))
      EOT

      assert_equal(40, jsarray.run(:[], 3).v)

      # Let's do method chainning
      jsarray.run(:<<, 100).run(:<<, 200).run(:to_s).v

      # run a block to a Ruby method from javascript
      B.eval(<<-EOT)
         data.run("map", "{ |x| print x}")
      EOT

      jsarray.run("map", "{ |x| print x }")
      jsarray.run("map!", "{ |x| x + 1}")
      
      B.eval(<<-EOT)
         console.log(data.run("to_s"))
      EOT

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "callback a jspacked Ruby Hash" do
      
      # Try the same with a hash
      hh = {"a" => 1, "b" =>2}

      B.hh = B.jspack(hh, scope: :external)
      
      # Retrieve the value of a key
      B.eval(<<-EOT)
        var h1 = hh.run('[]', "a")
        var h2 = hh.run('[]', "b")
      EOT

      assert_equal(1, B.h1.v)
      assert_equal(2, B.h2.v)

      B.hh.run("[]=", "c", 3)
      
      B.eval(<<-EOT)
         console.log(hh.run("to_s"))
      EOT
      
      B.hh.run("[]=", "d", 4)
      
      assert_equal(3, B.hh.run("[]", "c").v)
      assert_equal(4, B.hh.run("[]", "d").v)

    end
          
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "callback a jspacked object with internal scope" do

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "callback a jspacked MDArray" do

      B.mdarray = MDArray.double([2, 2], [1, 2, 3, 4])
      B.mdarray.run("[]", [1, 1])

=begin      
      B.eval(<<-EOT)
         console.log(mdarray.run("[]", 1, 1))
      EOT
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
