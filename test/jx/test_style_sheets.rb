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

  context "StyleSheet environment" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end

    #--------------------------------------------------------------------------------------
    # If a stylesheet is read from file, i.e., file:/// chrome does not allow reading
    # or changing the rules for security reasons.  In order to add a new stylesheet,
    # we can createElement("style") and add the rules to this element. Classes that
    # need to be implemented:
    # * HTMLStyleElement
    # * CSSStyleSheet
    # * CSSRuleList
    # * CSSStyleDeclaration
    #--------------------------------------------------------------------------------------

    should "get StyleSheets information" do

      B.eval(<<-EOT)
         var style = document.createElement("style");
         document.head.appendChild(style); // must append before you can access sheet property
         var sheet = style.sheet;
         sheet.insertRule("#blanc { color: white }", 0);
         sheet.insertRule("#mycolor { color: black }", 1);

         console.log(style);
         console.log(style.sheet);
         console.log(sheet instanceof CSSStyleSheet);
         console.log(sheet.rules);
         console.log(sheet.rules[0].style);
         console.log(sheet.rules[0].style.cssText);
         console.log(sheet.rules[1].style.cssText)
      EOT
      
      sss = B.style_sheets
      p sss
      p sss.length
      ss0 = sss[2]
      p ss0.disabled?
      p ss0.href
      p ss0.media
      p ss0.owner_node
      p ss0.parent_style_sheet
      p ss0.title
      p ss0.type
      rules = ss0.rules
      p rules
      # p rules.jsvalue[0].css_text
      

    end

  end

end
