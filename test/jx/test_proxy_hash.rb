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

      # Hash with symbols and strings as keys
      a = {:a=> 1, "b"=> 2, "c"=> 3, :d=> {:e=> 4, :f=> 5, "g"=> {"h"=> 6, "i"=>7}},
           "j"=> [1, 2, [3, [4, 5]]]}
      
      # hash with symbols and Strings as keys
      b = {"x"=> 100, "y"=> 200, "c"=> 300, d: 400}
      
      # Ruby hash proxies javascript 'data'
      B.data = a
      B.d2 = b
      
      B.eval(<<-EOT)

        var assert = chai.assert;

        // When the key is a ruby symbol, in javascript we need to use the 'fetch' method
        assert.equal(1, data.fetch("a"));
        // When the key is a String then '[]' can be used
        assert.equal(2, data["b"]);
        // Can also use '.' notation to reach a String key
        assert.equal(2, data.b);
        // However symbol keys cannot be reached with '.' notation
        assert.equal(null, data.a);
        // Somo more examples
        assert.equal(3, data["c"]);
        assert.equal(100, d2["x"]);

        // access deep data 
        assert.equal(4, data.fetch("d").fetch("e"));
        assert.equal(7, data.fetch("d").g.i);
        assert.equal(1, data.j[0]);
        assert.equal(4, data.j[2][1][0]);

      EOT
      
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "allow adding key, value data to a proxied ruby hash" do
      
      # New Ruby hash
      hh = {a: 1, b: 2}

      # Pack a Ruby hash into javascript hh variable.  We could also use B.proxy(hh)
      # instead of B.pack(hh).  Method pack return a java object and not a Ruby object.
      # This is ok here since the value is 'injected' into javascript.  Method proxy
      # return a Ruby object.  Using proxy is less efficient than pack.
      B.hh = hh
      
      # Retrieve the value of a key.  Keys in Javascript cannot be symbol, they have to
      # be strings.  Sol automatically converts strings to symbols and vice-versa.
      B.eval(<<-EOT)
        var h1 = hh.fetch("a");
        var h2 = hh.fetch("b");
      EOT

      assert_equal(1, B.h1)
      assert_equal(2, B.h2)

      # assign values to new keys.
      B.hh["c"] = 3

      # Not however that we cannot add a Symbol as key when going through a javascript
      # variable (hh in B)
      # assert_raise (RuntimeError) { B.hh[:d] = 4 }
      p B.hh

      # But, of course, we can still add symbols directly in the Ruby hash.  Doing this
      # way is more efficient than going through javascript.
      hh[:d] = 4

      # method 'store' converts a string key into a symbol key
      B.hh.store("f", 6)

      B.eval(<<-EOT)
        hh["e"] = 5;
        // add a value to the hash from this javascript
        hh.store("g", 7);
        console.log(hh.to_s());
      EOT

      # Both B.hh (javascript) and hh (ruby) hashes share the same backstore
      assert_equal(5, hh["e"])
      assert_equal(6, hh[:f])
      assert_equal(1, B.hh.fetch("a"))
      
    end

  end

end


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
