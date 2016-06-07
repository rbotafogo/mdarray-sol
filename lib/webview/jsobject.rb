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

require 'thread'

class Sol

  class JSObject

    attr_reader :jsobject
    attr_reader :jsvar
    attr_reader :refresh

    #------------------------------------------------------------------------------------
    # Builds a new Ruby JSObject or one of its more specific subclasses from the given
    # java jsobject or basic type
    #------------------------------------------------------------------------------------

    def build(jsobject)

      tmp_obj = nil

      if (jsobject.is_a? Java::ComSunWebkitDom::JSObject)
        tmp_obj = JSObject.new(jsobject)
      else
        return jsobject
      end
      
      if (tmp_obj.function?)
        JSFunction.new(@jsvar, jsobject)
      elsif (tmp_obj.array?)
        JSArray.new(jsobject)
      else
        tmp_obj
      end
      
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(jsobject)
      @jsobject = jsobject
      @jsvar = nil
      @refresh = false
      js
    end

    #----------------------------------------------------------------------------------------
    # Push the object into the JS evaluator.  Check to see if this object already has an JS
    # value (jsvar).  The jsvar is just a string of the form sc_xxxxxxxx. This string will be
    # an JS variable that holds the JSObject.  
    #----------------------------------------------------------------------------------------
    
    def js

      if (@jsvar == nil)
        
        # create a new variable name to hold this object inside JS
        @jsvar = "sc_#{SecureRandom.hex(8)}"
        
        # if this object already has a jsobject value then assign to @jsvar the existing
        # jsobject, otherwise, assign itself to @jsvar.  If a jsobject already exists
        # then set the refresh flag to true, so that we know that the jsobject was
        # changed.
        if (@jsobject.nil?)
          B.assign(@jsvar, self)
        else
          @refresh = true
          B.assign(@jsvar, @jsobject)
        end
        
        # Whenever a variable is injected in JS, it is also added to the stack.
        # After eval, every injected variable is removed from JS making sure that we
        # do not have memory leak.
        # Renjin.stack << self
        
      end
      
      @jsvar
      
    end

    #----------------------------------------------------------------------------------------
    # * @return true if this JSObject already points to a jsobject in JS environment
    #----------------------------------------------------------------------------------------
    
    def jsobject?
      jsobject != nil
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def function?
      B.typeof(self) == "function"
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def array?
      B.instanceof(self, "array")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof
      return "object"
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args)
      
      name = symbol.id2name
      member = @jsobject.getMember(name)
      # can be either a basic type or a JSObject.  Should create a method build and
      # build should check the type a wrap it if necessary
      if (member.is_a? Java::ComSunWebkitDom::JSObject)
        build(member)
      else
        member
      end
        
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

  end
  
end
  
require_relative 'jsfunction'
require_relative 'jsarray'
