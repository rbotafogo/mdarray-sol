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

class Sol

  class JSObject

    attr_reader :jsvalue
    attr_reader :jsvar
    attr_reader :refresh
    
    #------------------------------------------------------------------------------------
    # Builds a new Ruby JSObject or one of its more specific subclasses from the given
    # java jsvalue
    #------------------------------------------------------------------------------------

    def self.build(jsvalue)

      if (jsvalue.isArray())
        JSArray.new(jsvalue)
      elsif (jsvalue.isBoolean())
        JSBoolean.new(jsvalue)
      elsif (jsvalue.isBooleanObject())
        p "BooleanObject"
      elsif (jsvalue.isFunction())
        JSFunction.new(jsvalue)
      elsif (jsvalue.isNull())
        p "Null"
      elsif (jsvalue.isNumber())
        JSNumber.new(jsvalue.asNumber())
      elsif (jsvalue.isNumberObject())
        p "NumberObject"
      elsif (jsvalue.isObject())
        JSObject.new(jsvalue)
      elsif (jsvalue.isString())
        JSString.new(jsvalue)
      elsif (jsvalue.isStringObject())
        p "StringObject"
      elsif (jsvalue.isUndefined())
        p "Undefined"
      else

      end

    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(jsvalue)
      @jsvalue = jsvalue
      @jsvar = nil
      @refresh = false
      js
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def array?
      false
    end

    def boolean?
      false
    end

    def boolean_object?
      false
    end

    def function?
      false
    end

    def nil?
      false
    end

    def number?
      false
    end

    def number_object?
      false
    end
    
    def object?
      true
    end
    
    def string?
      false
    end
    
    def string_object?
      false
    end
    
    def undefined?
      false
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
        if (@jsvalue.nil?)
          B.assign(@jsvar, self)
        else
          @refresh = true
          B.assign(@jsvar, @jsvalue)
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
    
    def jsvalue?
      jsvalue != nil
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def set_member(name, value)
      Bridge.instance.send(@jsvalue, :setMember, name, value)
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args)
      
      name = symbol.id2name
      member = @jsvalue.getMember(name)

      if (member.is_a? Java::ComSunWebkitDom::JSObject)
        if (B.eval("#{@jsvar}['#{name}'] instanceof Function"))
          if (args.size > 0)
            if (args.size == 1 && args[0] == nil)
              args.pop
            end
            return B.eval("#{@jsvar}['#{name}'](#{B.parse(*args)})")
          end
        end
        build(member, *args)
      else
        member
      end
        
    end
        
  end
  
end

require_relative 'jsnumber'
require_relative 'jsfunction'
require_relative 'jsarray'
require_relative 'jsboolean'
require_relative 'jsstring'
