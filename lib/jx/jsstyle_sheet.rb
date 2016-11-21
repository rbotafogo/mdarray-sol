# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
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

=begin

StyleSheet.disabled


StyleSheet.href Read only

StyleSheet.media Read only
Returns a MediaList representing the intended destination medium for style information.

StyleSheet.ownerNode Read only
Returns a Node associating this style sheet with the current document.
StyleSheet.parentStyleSheet Read only
Returns a StyleSheet including this one, if any; returns null if there aren't any.
StyleSheet.title Read only
Returns a DOMString representing the advisory title of the current style sheet.
StyleSheet.typeRead only
Returns a DOMString representing the style sheet language for this style sheet.
=end

class Sol

  #==========================================================================================
  # 
  #==========================================================================================

  class CSSRule

    attr_reader :jsvar
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(parent, index)
      @jsvar = "css_rule_#{SecureRandom.hex(8)}"
      B.eval("var #{@jsvar} = #{parent}[#{index}]")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def css_text
      B.eval("#{@jsvar}.cssText")
    end
    
  end
  
  #==========================================================================================
  # 
  #==========================================================================================

  class CSSRules

    attr_reader :jsvar

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(style_sheet)
      p "rules #{style_sheet}"
      @jsvar = "css_rules_#{SecureRandom.hex(8)}"
      p B.eval("#{style_sheet}.rules")
      # B.eval("var #{@jsvar} = #{style_sheet}.cssRules")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def [](index)
      # p @jsvar
      B.eval("console.log(#{@jsvar})")
      CSSRule.new(@jsvar, index)
    end

  end

  #==========================================================================================
  # 
  #==========================================================================================

  class CSSStyleSheet

    attr_reader :jsvar
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(index)
      @jsvar = "css_style_sheet_#{SecureRandom.hex(8)}"
      p "init"
      B.eval("console.log(__style_sheets__[1].cssRules)")
      B.eval("var #{@jsvar} = __style_sheets__[#{index}]")
    end
    
    #------------------------------------------------------------------------------------
    # Is a Boolean representing whether the current stylesheet has been applied or not.    
    #------------------------------------------------------------------------------------

    def disabled?
      B.eval("#{@jsvar}.disabled")
    end
    
    #------------------------------------------------------------------------------------
    # Returns a DOMString representing the location of the stylesheet.
    #------------------------------------------------------------------------------------

    def href
      B.eval("#{@jsvar}.href")
    end

    #------------------------------------------------------------------------------------
    # Returns a MediaList representing the intended destination medium for style
    # information.
    #------------------------------------------------------------------------------------
    
    def media
      B.eval("#{@jsvar}.media")
    end
      
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def owner_node
      B.eval("#{@jsvar}.ownerNode")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def parent_style_sheet
      B.eval("#{@jsvar}.parentStyleSheet")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def title
      B.eval("#{@jsvar}.title")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def type
      B.eval("#{@jsvar}.type")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def rules
      B.eval("#{@jsvar}.rules")
      # CSSRules.new(@jsvar)
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def style_sheet?
      true
    end

  end
  
  #==========================================================================================
  # 
  #==========================================================================================

  class CSSStyleSheets

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def style_sheets?
      true
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def [](index)
      CSSStyleSheet.new(index)
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def length
      B.eval("__style_sheets__.length")
    end
    
  end

end
