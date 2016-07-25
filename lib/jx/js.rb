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

# require 'opal'
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
      
      def Message(event)
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
    #
    #------------------------------------------------------------------------------------

    def proxy(array)
      ProxyArray.new(array).jsvar
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

    def assign_window(property_name, data)
      window.setProperty(property_name, data)
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
      instanceOf(object, type)
    end

    #------------------------------------------------------------------------------------
    # Returns the given property from 'window'
    #------------------------------------------------------------------------------------

    def pull(name)
      eval("#{name};")
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

    def function(symbol = nil, definition)

      name = (symbol)? symbol.id2name : "_tmpvar_"
      eval("var #{name} = function #{definition}")
      eval("#{name}")
      
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def load(file)
      @browser.executeJavaScriptAndReturnValue(file.read)
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def jspack(obj, scope: :external)
      Callback.pack(obj, scope: scope)
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args)

      name = symbol.id2name
      name.gsub!(/__/,"$")

      if name =~ /(.*)=$/
      # ret = assign_window($1, args[0])
        ret = assign_window($1, process_args(args)[0])
      else
        if ((ret = pull(name)).function?)
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
    #
    #------------------------------------------------------------------------------------

    def process_args(args)

      args.map do |x|
        case x
        when Sol::JSObject
          x.jsvalue
        when Hash, Array
          JSONString.new(x.to_json)
        else
          x
        end
      end
      
    end
        
  end
  
end

