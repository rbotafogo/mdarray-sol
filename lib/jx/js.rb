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

require 'opal'
require 'json'
require_relative 'jsobject'

class Sol

  
  #==========================================================================================
  # Class to communicate with the embedded browser (Webview), by sending javascript
  # messages
  #==========================================================================================

  class Js
    java_import com.teamdev.jxbrowser.chromium.events.ConsoleListener
    java_import com.teamdev.jxbrowser.chromium.JSONString
    
    #========================================================================================
    # Class RBListener listen for the Browser console.log messages
    #========================================================================================
    
    class RBListener
      include ConsoleListener
      
      def onMessage(event)
        puts "JS> #{event.getMessage()}"
      end
    end

    #========================================================================================
    #
    #========================================================================================
    
    attr_accessor :browser
        
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(browser)
      @browser = browser

      # listen for console events
      @browser.addConsoleListener(RBListener.new)
      
    end
    
    #------------------------------------------------------------------------------------
    # Gets the Brwoser 'window' object
    #------------------------------------------------------------------------------------

    def window
      @browser.executeJavaScriptAndReturnValue("window")
    end

    #------------------------------------------------------------------------------------
    # Gets the browser 'document' object
    #------------------------------------------------------------------------------------

    def document
      @browser.executeJavaScriptAndReturnValue("document")
    end

    #------------------------------------------------------------------------------------
    # Evaluates the javascript script synchronously and then pack the result in a
    # Ruby JSObject
    #------------------------------------------------------------------------------------

    def eval(scrpt)
      JSObject.build(@browser.executeJavaScriptAndReturnValue(scrpt))
    end
    
    #------------------------------------------------------------------------------------
    # Assign the data to the given named window property
    #------------------------------------------------------------------------------------

    def assign(object, property_name, data)
      @browser.object.setProperty(property_name,data)
      object
    end

    #------------------------------------------------------------------------------------
    # Assign the data to the given named window property
    #------------------------------------------------------------------------------------

    def assign_window(property_name, data)
      window = B.window
      window.setProperty(property_name, data)
      window
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof(object)
      B.eval("typeof(#{object.jsvar})")
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def instanceof(object, type)
      p "#{object.jsvar} instanceof #{type.jsvalue}"
      B.eval("#{object.jsvar} instanceof #{type.jsvalue}")
    end

    #------------------------------------------------------------------------------------
    # Returns the given property from 'window'
    #------------------------------------------------------------------------------------

    def pull(name)
      B.eval("#{name};")
    end

    #------------------------------------------------------------------------------------
    # Duplicates the given Ruby data into a javascript object in the Browser
    #------------------------------------------------------------------------------------

    def dup(name, data)
      assign_window(name.to_s, JSONString.new(data.to_json))
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def function(symbol, definition)
      
      name = symbol.id2name
      B.eval("var #{name} = function #{definition}")
      
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args)

      name = symbol.id2name
      name.gsub!(/__/,"$")
      
      if name =~ /(.*)=$/
        ret = assign_window($1,args[0])
      else
        if ((ret = B.pull(name)).function?)
          if (args.size > 0)
            if (args.size == 1 && args[0].nil?)
              ret = ret.send
            else
              ret = ret.send(*args)
            end
          end
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
          params << var.js
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

