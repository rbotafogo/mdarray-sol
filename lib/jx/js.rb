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

require 'singleton'

require_relative 'jsobject'

class Sol
  
  #==========================================================================================
  # Class to communicate with the embedded browser (Webview), by sending javascript
  # messages
  #==========================================================================================

  class Js
    include Singleton

    attr_accessor :browser
    attr_reader :mutex
    attr_reader :resource
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize
      @mutex = Mutex.new
      @resource = ConditionVariable.new
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof(obj)
      case obj
      when String
        "string"
      when Numeric
        "number"
      when TrueClass
        "boolean"
      else
        B.eval("typeof #{obj.js}")
      end
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def instanceof(obj, type)
      
      case type
      when "array"
        B.eval("#{obj.js} instanceof Array")
      when "function"
        B.eval("#{obj.js} instanceof Function")
      when "object"
        B.eval("#{obj.js} instanceof Object")
      else
        raise "Wrong type: #{type} for instanceof operator"
      end

    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def eval(scrpt)

      # p scrpt
      JSObject.build(@browser.executeJavaScriptAndReturnValue(scrpt))

    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def assign(name, data)
      @browser.executeJavaScriptAndReturnValue("var name = #{data}")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def pull(name)
      B.eval("#{name};")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------
    
    def method_missing(symbol, *args)
      
      name = symbol.id2name
      
      if name =~ /(.*)=$/
        ret = assign($1,args[0])
      else
        if (eval("#{name} instanceof Function") )
          ret = eval("#{name}(#{parse(*args)})")
        else
          ret = eval("#{name}")
        end
      end
      
      ret
      
    end
    
    #------------------------------------------------------------------------------------
    # Deletes all divs from the Browser
    #------------------------------------------------------------------------------------
    
    def delete_all
      eval(<<-EOS)
        d3.selectAll(\"div\").remove();
      EOS
    end
    
    #----------------------------------------------------------------------------------------
    # Parse an argument and returns a piece of R script needed to build a complete R
    # statement.
    #----------------------------------------------------------------------------------------
    
    def parse(*args)
      
      params = Array.new
      
      args.each do |arg|
        case arg
        when Numeric
          params << arg
        when String
          params << "\"#{arg}\""
        when Symbol
          var = eval("#{arg.to_s}")
          params << var.r
        when TrueClass
          params << "true"
        when FalseClass
          params << "false"
        when nil
          params << "null"
        when Hash
          arg.each_pair do |key, value|
            # k = key.to_s.gsub(/__/,".")
            params << "#{key.to_s.gsub(/__/,'.')} = #{parse(value)}"
            # params << "#{k} = #{parse(value)}"
          end
        when Sol::JSObject, Array, MDArray
          params << arg.js
        else
          raise "Unknown parameter type for JS: #{arg}"
        end
        
      end
      
      params.join(",")
      
    end
    
  end
    
end

