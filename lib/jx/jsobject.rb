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
        JSBooleanObject.new(jsvalue)
      elsif (jsvalue.isFunction())
        JSFunction.new(jsvalue)
      elsif (jsvalue.isNumber())
        JSNumber.new(jsvalue)
      elsif (jsvalue.isNumberObject())
        JSNumberObject.new(jsvalue)
      elsif (jsvalue.isString())
        JSString.new(jsvalue)
      elsif (jsvalue.isStringObject())
        JSStringObject.new(jsvalue)
      elsif (jsvalue.isUndefined())
        JSUndefined.new(jsvalue)
      elsif (jsvalue.isObject())
        JSObject.new(jsvalue)
      else

      end

    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(jsvalue)
      @jsvalue = jsvalue
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def value
      raise "Method value undefined for this class"
    end
    
    #------------------------------------------------------------------------------------
    # v is just an alias of the value method that is implemented by some subclasses of
    # jsobject
    #------------------------------------------------------------------------------------

    def v
      value
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof
      B.eval("'object'")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def instanceof(constructor)
      B.instanceOf(@jsvalue, constructor.jsvalue)
    end
    
    #----------------------------------------------------------------------------------------
    # * @return true if this JSObject already points to a jsobject in JS environment
    #----------------------------------------------------------------------------------------
    
    def jsvalue?
      @jsvalue != nil
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def jsend(object, function, *args)
      args = nil if (args.size == 1 && args[0].nil?)
      JSObject.build(function.invoke(object, *(args.to_java)))
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def assign(property_name, data)
      
      if (data.is_a? Sol::JSObject)
        @jsvalue.setProperty(property_name, data.jsvalue)
      else
        @jsvalue.setProperty(property_name, data)
      end
      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args)
      
      name = symbol.id2name
      
      if name =~ /(.*)=$/
        ret = assign($1, B.process_args(args)[0])
      elsif ((member = @jsvalue.getProperty(name)).function? && args.size > 0)
        ret = jsend(@jsvalue, member, *args)
      else
        ret = JSObject.build(member)
      end
      ret
      
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

  end
  
end

require_relative 'jsnumber'
require_relative 'jsnumberobject'
require_relative 'jsfunction'
require_relative 'jsarray'
require_relative 'jsboolean'
require_relative 'jsbooleanobject'
require_relative 'jsstring'
require_relative 'jsstringobject'
require_relative 'jsundefined'
require_relative 'callback'
