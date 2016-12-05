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
    
    should "callback a packed Ruby Hash" do
      
      # Try the same with a hash
      hh = {a: 1, b: 2}

      B.hh = B.pack(hh)
      
      # Retrieve the value of a key.  Keys in Javascript cannot be symbol, they have to
      # be strings.  Sol automatically converts strings to symbols and vice-versa.
      B.eval(<<-EOT)
        var h1 = hh.fetch("a");
        var h2 = hh.fetch("b");
      EOT

      assert_equal(1, B.h1)
      assert_equal(2, B.h2)
      B.hh["c"] = 3
      
      B.eval(<<-EOT)
         console.log(hh.to_s());
      EOT
      
=begin      
      B.hh.run("[]=", "d", 4)
      
      assert_equal(3, B.hh.run("[]", "c"))
      assert_equal(4, B.hh.run("[]", "d"))
=end
    end
=begin

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



=begin

THIS SHOULD BE THROWN AWAY PROBABLY....


    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "proxy ruby array inside ruby object" do

      a1 = [1, 2, 3]
      a2 = [4, 5]

      p1 = Sol::RBProxyObject.new(a1)
      p2 = Sol::RBProxyObject.new(a2)

      p p1
      
      assert_equal(1, p1[0])
      assert_equal(5, p2[1])

      # Not sure that returning 'true' here is a good idea
      assert_equal(true, (p1.is_a? Array))
      
      assert_equal([1, 2, 3, 4, 5], p1.concat(p2))
      assert_equal(4, p1.fetch(3))
      assert_equal("ooops", p1.fetch(100, "ooops"))
      p1.each { |d| p d }

      # let´s now proxy the a2 array and send it to javascript
      proxy = B.proxy(a2)
      p proxy
      
    end

=end
