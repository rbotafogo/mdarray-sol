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

    should "proxy ruby object inside ruby object" do

      a1 = [1, 2, 3]
      a2 = [4, 5]

      p1 = Sol::RBProxyObject.new(a1)
      p2 = Sol::RBProxyObject.new(a2)

      p p1[0]
      p p2[1]

      p p1.is_a? Array
      p p1.concat(p2)
      p p1.fetch(3)
      p p1.fetch(100, "ooops")
      p1.each { |d| p d }
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
=begin
    should "access proxied Ruby Array" do
      
      # create an array of data in Ruby
      array = [1, 2, 3, 4]
      proxy = B.proxy(array)

      B.ruby_array = proxy
      
      B.eval(<<-EOT)
         console.log(ruby_array.length);
         console.log(ruby_array[0]);
         console.log(ruby_array[3]);
         console.log(ruby_array["[]"](2));

         // note that we can call '[]' with negative index
         console.log(ruby_array["[]"](-1));

         // adding element to the array will add it to the ruby array
         ruby_array["<<"](5);

         // it is also possible to call method 'each' that expects a block passing
         // a function in place of the block
         ruby_array["each"](function(x) {console.log(x);});
      EOT

      assert_equal(5, array[4])

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "access complex Ruby arrays" do
      
      # create an array of data in Ruby
      array = [[1, 2], [3, 4], [5, 6]]
      proxy = B.proxy(array)

      B.ruby_array = proxy
      
      B.eval(<<-EOT)
         // console.log(ruby_array.length);
         console.log(ruby_array[0][0]);
         console.log(ruby_array[2][1]);
      EOT

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "be able to call ruby methods with ruby arguments" do
      a1 = [1, 2, 3, 4]
      a2 = [5, 6, 7]
      
      B.a1 = B.proxy(a1)
      B.a2 = B.proxy(a2)

      B.eval(<<-EOT)
        console.log(a1.each(function(x) { console.log(x); }));
        // console.log(a1.concat(a2));
      EOT

    end
=end    
=begin
    should "callback a jspacked Ruby Array" do

      # create an array of data in Ruby
      array = [1, 2, 3, 4]

      # Pack the array and assign it to an R variable.
      B.ruby_array = B.jspack(array)
      assert_equal(4, B.ruby_array.run("length"))

      # Check that the array is available in the Browser
      B.eval(<<-EOT)
        console.log(ruby_array.run("length"))
      EOT

      # add a new element to the array
      B.ruby_array.run("<<", 5)
      assert_equal(2, B.ruby_array.run("[]", 1))
      assert_equal(5, B.ruby_array.run(:[], 4))
      # check that both the Ruby array and the Browser array use the same
      # backing store, i.e., array should now have the element 5:
      assert_equal(5, array[4])

      # Check that we can still access the ruby_array from within javascript
      B.eval(<<-EOT)
        console.log(ruby_array.run("length"))
        console.log(ruby_array.run("[]", 4))
      EOT

      # Set a Ruby variable to point to an object in the Browser
      B.jsarray = B.jspack([10, 20, 30, 40])
      B.jsarray.run("<<", 10)

      # make jsarray available to javascript
      B.data = B.jsarray
      B.eval(<<-EOT)
         console.log("Expected value is 10 and returned is: " + data.run("[]", 4))
      EOT

      assert_equal(40, B.jsarray.run(:[], 3))

      # Let's do method chainning
      B.jsarray.run(:<<, 100).run(:<<, 200).run(:to_s)

      # run a block to a Ruby method from javascript
      B.eval(<<-EOT)
         data.run("map", "{ |x| print x}")
      EOT

      B.jsarray.run("map", "{ |x| print x }")
      B.jsarray.run("map!", "{ |x| x + 1}")
      
      B.eval(<<-EOT)
         console.log(data.run("to_s"))
      EOT

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "callback a jspacked Ruby Hash" do
      
      # Try the same with a hash
      hh = {a: 1, b: 2}

      B.hh = B.jspack(hh, scope: :external)
      
      # Retrieve the value of a key.  Keys in Javascript cannot be symbol, they have to
      # be strings.  Sol automatically converts strings to symbols and vice-versa.
      B.eval(<<-EOT)
        var h1 = hh.run('[]', "a")
        var h2 = hh.run('[]', "b")
      EOT

      assert_equal(1, B.h1)
      assert_equal(2, B.h2)

      B.hh.run("[]=", "c", 3)
      
      B.eval(<<-EOT)
         console.log(hh.run("to_s"))
      EOT
      
      B.hh.run("[]=", "d", 4)
      
      assert_equal(3, B.hh.run("[]", "c"))
      assert_equal(4, B.hh.run("[]", "d"))

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
  end
  
end
