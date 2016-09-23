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
      # include DisposeListener
      
      def onMessage(event)
        puts "JS> #{event.getMessage()}"
      end
      
    end

    #========================================================================================
    #
    #========================================================================================
    
    attr_reader :browser
        
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
    # Calls Chrome printing popup interface
    #------------------------------------------------------------------------------------

    def print_page
      @browser.print
    end

    #------------------------------------------------------------------------------------
    # Returns a list of StyleSheet's
    #------------------------------------------------------------------------------------

    def style_sheets
      eval(<<-EOT)
        var __style_sheets__ = document.styleSheets;
      EOT
      CSSStyleSheets.new
    end
    
    #------------------------------------------------------------------------------------
    # Loads a javascript file relative to the callers directory
    #------------------------------------------------------------------------------------

    def load(filename)
      
      file = caller.first.split(/:\d/,2).first
      dir = File.dirname(File.expand_path(file))
      
      scrpt = "" 
      begin
        file = File.new("#{dir}/#{filename}", "r") 
        while (line = file.gets)
          scrpt << line
        end
        file.close
      rescue => err
        puts "Exception: #{err}"
        err
      end

      @browser.executeJavaScriptAndReturnValue(scrpt)
      
    end

    #------------------------------------------------------------------------------------
    # Evaluates the javascript script synchronously and then pack the result in a
    # Ruby JSObject
    # @param scrpt [String] a javascript script to be executed synchronously
    # @return [JSObject] a JSObject or one of its subclasses
    #------------------------------------------------------------------------------------

    def eval(scrpt)
      JSObject.build(@browser.executeJavaScriptAndReturnValue(scrpt))
    end
            
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof(object)
      object.typeof
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def instanceof(object, type)
      B.rr.instanceOf(object, type)
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def push(value)
      B.rr.identity(value)
    end
    
    #------------------------------------------------------------------------------------
    # Returns the given property from 'window'
    #------------------------------------------------------------------------------------

    def pull(name)
      eval("#{name};")
    end
    
    #------------------------------------------------------------------------------------
    # Creates a new function in javascript and returns it as a jsfunction
    # @param symbol [Symbol] the name of the function in javascript namespace.  If not
    # given, then a temporary name is used just to be able to create the function.
    # @return [JSFunction] a jsfunction.
    #------------------------------------------------------------------------------------

    def function(symbol = nil, definition)

      name = (symbol)? symbol.to_s : "_tmpvar_"
      eval("var #{name} = function #{definition}")
      eval("#{name}")
      
    end
        
    #------------------------------------------------------------------------------------
    # Duplicates the given Ruby data into a javascript object in the Browser
    # @param name [Symbol, String] the name of the javascript variable into which to dup
    # @param data [Object] a Ruby object
    #------------------------------------------------------------------------------------

    def dup(symbol = nil, data)
      
      name = (symbol)? symbol.to_s : "_tmpvar_"
      assign_window(name.to_s, JSONString.new(data.to_json))
      eval("#{name}")
      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def jspack(obj, scope: :external)
      assign_window("__pack__", Callback.pack(obj, scope: scope))
      eval("__pack__")
    end

    #------------------------------------------------------------------------------------
    # Proxies the ruby object (obj) into a javascript object
    #------------------------------------------------------------------------------------

    def proxy(obj, scope: :external)
      B.RubyProxy.new(jspack(obj, scope: scope))
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args, &blk)
      
      if (blk)
        B.block = Sol::Callback.new(blk)
        B.eval(<<-EOT)
          function bk(...args) { return block.run("call", args); }
        EOT
        (args.size > 0 && args[-1].nil?)? args[-1] = B.bk : args << B.bk 
      end
      
      name = symbol.to_s
      name.gsub!(/__/,"$")

      if name =~ /(.*)=$/
        ret = assign_window($1, process_args(args)[0])
      else
        if (((ret = pull(name)).is_a? Sol::JSObject) && ret.function?)
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

    #------------------------------------------------------------------------------------
    # Converts a Ruby object (argument) into a javascript object to run in a javascript
    # script
    #------------------------------------------------------------------------------------

    def process_args(args)

      args.map do |arg|
        case arg
        when Sol::Callback
          arg
        when Sol::JSObject
          arg.jsvalue
        when Symbol
          arg.to_s
        when Hash, Array
          proxy(arg, scope: :all).jsvalue
        else
          arg
        end
      end
      
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    # private
    
    #------------------------------------------------------------------------------------
    # Assign the data to the given named window property
    #------------------------------------------------------------------------------------

    def assign_window(property_name, data)
      window.setProperty(property_name, data)
    end
        
  end
  
end

