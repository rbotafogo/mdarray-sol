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
    should "proxy a Ruby hash" do

      # Hash with symbols as keys
      a = {a: 1, b: 2, c: 3, d: {e: 4, f: 5, g: {h: 6, i:7}}}

      # hash with symbols and Strings as keys
      b = {x: 100, y: 200, c: 300, "d" => 400}
      
      # Ruby hash proxies javascript 'data'
      B.data = B.proxy(a)
      B.d2 = B.proxy(b)
      
      # load a javascript file to test hash usage from javascript.  assert clauses in the
      # javascript file will not be computed on test statistics, unfortunately.
      B.load("test_ruby_hash.js")

      # key :j was added in the javascript file
      assert_equal("[:b, :c, :d, :j]", a.keys.to_s)
      assert_equal("Hello from js", a["j"])

      # add new (key, value) to hash
      a["k"] = "new val"

      # this new (key, value) pair is available to 'data' in javascript
      B.eval(<<-EOT)
        assert.equal("new val", data.k);
        // data.each_pair (function(param) { console.log(param[1]); } )
      EOT

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "proxy Ruby arrays" do

      a = [1, 2, 3, 4]
      B.data = B.proxy(a)
      
      # load a javascript file to test arrays.  assert clauses in the javascript file
      # will not be shown as tests, unfortunately.
      B.load("test_ruby_array.js")

    end
=end    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "proxy Ruby lambdas" do
      
      # func = Sol::Callback.new(Proc.new { |x| x })
      block = Sol::Callback.new { |x| x }
      p block.run("call", 10)
      B.block = block
      
      p B.block.run("call", 50)
      
      B.eval(<<-EOT)
        console.log(block.run("call", 100));
        function bk(x) { return block.run("call", x); }
        console.log(bk(500));
      EOT
        
    end

  end
  
end


=begin      
      md = MDArray.double([2, 2], [1, 2, 3, 4])
      B.data = B.proxy(md)
      
      B.eval(<<-EOT)
        console.log(data.get([0, 0]));
        console.log(data.get([0, 1]));
      EOT
=end
