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

  context "MDArray" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "callback a jspacked MDArray" do

      mdarray = MDArray.double([2, 2], [1, 2, 3, 4])
      B.mdarray = B.jspack(mdarray)

      B.eval(<<-EOT)
         console.log(mdarray.run("[]", 0, 0))
         console.log(mdarray.run("[]", 1, 1))
         console.log(mdarray.run("get", [1, 1]))
         mdarray.run("[]=", 1, 1, 10)
         console.log(mdarray.run("get", [1, 1]))
         mdarray.run("set", [0, 0], 100)
         console.log(mdarray.run("get", [0, 0]))
      EOT

      # mdarray and B.mdarray share the same backing store
      mdarray.print

      # showing the reverse, i.e., making changes on variable mdarray in Ruby will
      # affect B.mdarray
      mdarray[0, 1] = 85
      B.eval(<<-EOT)
         console.log(mdarray.run("[]", 0, 1))
      EOT

    end

  end

end
