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
    # This test file will test compatibility between Ruby and Javascript method/function
    # calls.  For this we will create a Javascript function that returns a Javascript
    # object with the following signatures:
    # * JSObject f(JSArray, JSObject, function)
    # * JSObject f(JSArray, JSObject, block)
    # * JSObject f(JSArray, Hash, function)
    # * JSObject f(JSArray, Hash, block)
    # * JSObject f(Array, JSObject, function)
    # * JSObject f(Array, JSObject, block)
    # * JSObject f(Array, Hash, function)
    # * JSObject f(Array, Hash, block)
    #--------------------------------------------------------------------------------------

    setup do 

      B.eval(<<-EOT)
        jsarray = ["a", "b", "c", "d"]

        jsobject = {
          a: 1,
          b: 2, 
          z: 10,
          y: 20
        }

        function test_compat(arr, obj, func) {
          var res = [];
          for (i = 0; i < arr.length; i++) {
            res[i] = func.call(this, arr[i], obj);
          }
          return res; 
        }

        var assert = chai.assert;

      EOT

      rbarray = [1, 2, 3, 4]
      rbhash = {a: 1, b: 2, c: 10, d: 20}
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
=begin    
    should "JSObject f(JSArray, JSObject, function)" do
      
      B.eval(<<-EOT)
        function has_element(elmt, obj) {
          return obj.hasOwnProperty(elmt);
        }
        console.log(test_compat(jsarray, jsobject, has_element).toString());
        assert.equal("true,true,false,false", 
                     test_compat(jsarray, jsobject, has_element).toString());
      EOT

      p B.test_compat(B.jsarray, B.jsobject, B.has_element)[0].v
      
    end
=end
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "JSObject f(JSArray, JSObject, block)" do
      
      block = Sol::Callback.new { |elmt, obj|
        obj.hasOwnProperty elmt
      }
      
      B.block = block

      B.eval(<<-EOT)

        function bk(elmt, obj) { 
          return block.run("call", elmt, obj); }

        console.log(test_compat(jsarray, jsobject, bk).toString());
      EOT

    end
    
  end

end

=begin
      # func = Sol::Callback.new(Proc.new { |x| x })
      block = Sol::Callback.new { |x| x }
      p block.run("call", 10)
      B.block = block
      
      p B.block.run("call", 50).v
      
      B.eval(<<-EOT)
        console.log(block.run("call", 100));
        function bk(x) { return block.run("call", x); }
        console.log(bk(500));
      EOT
=end
