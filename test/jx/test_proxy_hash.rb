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

    should "proxy a Ruby hash" do

      # Hash with symbols as keys
      a = {a: 1, b: 2, c: 3, d: {e: 4, f: 5, g: {h: 6, i:7}},
           j: [1, 2, [3, [4, 5]]]}
      
      # hash with symbols and Strings as keys
      b = {x: 100, y: 200, c: 300, "d" => 400}
      
      # Ruby hash proxies javascript 'data'
      B.data = B.proxy(a)
      B.d2 = B.proxy(b)
      
      B.eval(<<-EOT)
        var assert = chai.assert;
                
        // retrieve the property by use of '[]'
        assert.equal(1, data["a"]);
        // retrieve the property by use of '.'
        assert.equal(1, data.a);
        // call a function on the data
        assert.equal(1, data.fetch("a"));

        assert.equal(3, data["c"]);
        assert.equal(100, d2["x"]);

        // In hashes, strings are converted to symbols.  Cannot retrieve key "d"
        // in d2 with '[]'
        assert.equal(null, d2["d"]);
        
        // In order to retrieve a string key, we need to use the fetch with a second
        // argument set to 'false'
        assert.equal(400, d2.fetch("d", false));
        
        // access deep data 
        assert.equal(4, data.d.e);
        assert.equal(7, data.d.g.i);
        assert.equal(1, data.j[0]);
        assert.equal(4, data.j[2][1][0]);
      EOT
      
=begin      
      # load a javascript file to test hash usage from javascript.  assert clauses in the
      # javascript file will not be computed on test statistics, unfortunately.
      B.load("test_ruby_hash.js")

      # key :j was added in the javascript file
      # assert_equal("[:b, :c, :d, :j]", a.keys.to_s)
      assert_equal("Hello from js", a["j"])

      # add new (key, value) to hash
      a["k"] = "new val"

      # this new (key, value) pair is available to 'data' in javascript
      B.eval(<<-EOT)
        assert.equal("new val", data.k);
        // data.each_pair (function(param) { console.log(param[1]); } )
      EOT
=end
    end
    
  end

end


