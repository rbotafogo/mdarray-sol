# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
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

class Sol

  class JSObject

    attr_reader :jsvalue
    # attr_reader :scope
    
    #------------------------------------------------------------------------------------
    # Builds a new Ruby JSObject or one of its more specific subclasses from the given
    # java jsvalue
    #------------------------------------------------------------------------------------

    def self.build(jsvalue, scope = B.document)

      if (jsvalue.isBoolean())
        jsvalue.getBooleanValue()
      elsif (jsvalue.isBooleanObject())
        jsvalue.getBooleanValue()
      elsif (jsvalue.isNumber())
        jsvalue.getNumberValue()
      elsif (jsvalue.isNumberObject())
        jsvalue.getNumberValue()
      elsif (jsvalue.isString())
        jsvalue.getStringValue()
      elsif (jsvalue.isStringObject())
        jsvalue.getStringValue()
      elsif (jsvalue.isArray())
        JSArray.new(jsvalue.asArray(), scope)
      elsif (jsvalue.isFunction())
        JSFunction.new(jsvalue.asFunction(), scope)
      elsif (jsvalue.isObject())
        JSObject.new(jsvalue, scope)
      elsif (jsvalue.isUndefined())
        JSUndefined.new(jsvalue, scope)
      elsif (jsvalue.is_a? Java::ComTeamdevJxbrowserChromium::am)
        raise "This is probably a Symbol"
      else
        raise "Unknown jsvalue type #{jsvalue}"
      end

    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(jsvalue, scope = nil)
      
      @jsvalue = jsvalue
      @scope = scope
      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof
      B.push("object")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def instanceof(constructor)
      B.rr.instanceOf(@jsvalue, constructor.jsvalue)
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def assign(property_name, data)
      @jsvalue.setProperty(property_name, data) 
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args, &blk)

      # if block is given, then create a javascript function that will call the block
      # passing the args
      args.push(B.blk2func(blk)) if (blk)

      name = symbol.id2name

      if name == "[]="
        assign(*(B.process_args(args)))
      elsif name =~ /(.*)=$/
        assign($1, B.process_args(args)[0])
      elsif (@jsvalue.undefined?)
        raise "Cannot extract property '#{name}' from undefined object"
      elsif ((member = @jsvalue.getProperty(name)).function? && args.size > 0)
        B.invoke(@jsvalue, member, *(B.process_args2(args)))
      else
        # Build a JSObject in the scope of @jsvalue
        JSObject.build(member, @jsvalue)        
      end
      
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

require_relative 'jsfunction'
require_relative 'jsarray'
require_relative 'jsstyle_sheet'
require_relative 'jsundefined'
require_relative 'callback'
require_relative 'proxy_array'
# require_relative 'jssymbol'


