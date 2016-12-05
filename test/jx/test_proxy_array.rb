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

    should "proxy flat ruby array" do

      a1 = [1, 2, 3]
      a2 = [4, 5]
      
      # p1 and p2 are proxy elements for arrays a1 and a2.  They will work as array
      # in ruby
      p1 = B.proxy(a1)
      p2 = B.proxy(a2)

      assert_equal(1, p1[0])
      assert_equal(5, p2[1])

      # call method concat
      assert_equal([1, 2, 3, 4, 5], p1.concat(p2))

      # ... and method fetch
      assert_equal(4, p1.fetch(3))
      assert_equal("ooops", p1.fetch(100, "ooops"))

      # ... and each
      puts "should print values from 1 to 5 as ruby output"
      p1.each { |d| p d }

      # Now lets see p1 and p2 in javascript
      B.p1, B.p2 = p1, p2
      
      B.eval(<<-EOT)
        var assert = chai.assert;
        // Check that proxied arrays share the same data as the original ruby arrays
        assert.equal(2, p1[1]);
        assert.equal(5, p1[4]);
        assert.equal(5, p2[1]);
        assert.equal(5, p1.length);

        // should also allow negative indices for array access
        assert.equal(5, p1[-1]);
        assert.equal(2, p1[-4]);

        // call ruby functions on the array, including functions that require a block
        // or have names that do not exist in javascript
        console.log("should output values 1 to 5 in javascript output");
        p1.each(function(x) { console.log(x); });
        p2["<<"] = 6

        // concat the two arrays since this is not yet possible with the concat 
        // method
        p2.each(function(x) { p1["<<"] = x; });

      EOT

=begin      
      # These do not work yet.
      B.eval(<<-EOT)
        p1.concat(p2);
      EOT
=end

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "proxy nested ruby arrays" do

      a1 = [1, 2, 3]
      a3 = [[1, 2], [3, 4], [5, 6, [7, [8, 9]]]]

      B.p1 = B.proxy(a1)
      B.p3 = B.proxy(a3)

      B.eval(<<-EOT)
        var assert = chai.assert;

        // access each element of the array and call to_s on them.  Note that calling
        // to_s requires '()', otherwise a function is returned
        console.log("should print the array elements of: [[1, 2], [3, 4], [5, 6, [7, [8, 9]]]]");
        p3.each(function(x) { console.log(x.to_s()); })      
        
        // Merge p3 with p1, equivalent to p1.concat(p2) but less efficient
        // probably since this is done elementwise
        p3.each(function(x) { p1["<<"] = x; });

        // 4th element of p1 is now the pair [1, 2]
        assert.equal("[1, 2]", p1[3].to_s())

        // access deep nested element
        assert.equal(6, p1[5][1]);
        assert.equal(8, p3[2][2][1][0]);
        
      EOT

      # Note that inspect with 'p' shows IRBObjects
      puts "This is an inspection of the array.  Note that there are Sol::IRBObject"
      puts "Sol::IRBObjects are ruby objects packaged for use in javascript"
      p a1

      # ... but puts makes the elements look like normal array elements
      puts "But a normal puts will show the array as a normal array"
      puts a1
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "Allow access directly from a js file" do
      
      B.data = [1, 2, 3, 4]
      B.d2 = [10, 20, 30, 40, 50, 60]
      
      # load a javascript file to test arrays.  assert clauses in the javascript file
      # will not be shown as tests, unfortunately.
      B.load("test_ruby_array.js")
      
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "proxy nested arrays and hashes" do

      a1 = [{name: "John", "age" => 25}, {name: "Mary", "age" => 30},
            {name: "Paul", "age" => 18}, {name: "Anton", "age" => 45}]

      B.data = B.proxy(a1)

      B.eval(<<-EOT)
        var assert = chai.assert;

        assert.equal("John", data[0].fetch("name"));
        assert.equal(25, data[0].age);
        assert.equal("Anton", data[3].fetch("name"));
        assert.equal(18, data[2].age);
      EOT

    end
    
  end

end
