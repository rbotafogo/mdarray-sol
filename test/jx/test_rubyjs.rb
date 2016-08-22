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
=begin
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
    
    should "receive jspacked object from an internal Ruby objects" do

      # create a Ruby array of hashes with data
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

      # push the data to the Browser without copying
      B.data = B.jspack(data)

      # check that we can access both the array and the hash content from javascript
      B.eval(<<-EOT)
        console.log(data.run("length"))
        // Hash keys should be access by a string in javascript
        console.log(data.run("[]", 4).run("[]", "date"))
      EOT

    end

=end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "proxy arrays" do

      a = [1, 2, 3, 4]
      B.pa = B.jspack(a)
      
      B.eval(<<-EOT)
        var proxy = new RubyProxy(pa);
        proxy[0]
        proxy[1]
        proxy[2]
        proxy[3]
      EOT

      # B.proxy crashes since this has no arguments
      # B.proxy[0]
      
    end
    
  end
  
end
