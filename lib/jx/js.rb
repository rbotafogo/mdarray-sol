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

require 'benchmark'

require 'json'
require_relative 'jsobject'
require_relative 'irbobject'

class Sol
  
  #==========================================================================================
  # Class to communicate with the embedded browser (jxBrowser), by sending javascript
  # messages
  #==========================================================================================

  class Js
    java_import com.teamdev.jxbrowser.chromium.events.ConsoleListener
    java_import com.teamdev.jxbrowser.chromium.JSONString
    java_import com.teamdev.jxbrowser.chromium.SavePageType

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
    # @attr_reader [Browser] jxBrowser instance
    # @attr_reader identity [jsFunction] A javascript function that implements the identity
    # function
    # @attr_reader instanceOf [jsFunction] A javascript function that returns if a JSObject
    # is an instance of a class
    #========================================================================================
    
    attr_reader :browser
    attr_accessor :identity
    attr_accessor :instanceOf
        
    #------------------------------------------------------------------------------------
    # @param browser [Browser] the jxBrowser instance
    #------------------------------------------------------------------------------------

    def initialize(browser)

      @browser = browser

      # listen for console events
      @browser.addConsoleListener(RBListener.new)
      
    end
        
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof(object)
      object.typeof
    end

    #------------------------------------------------------------------------------------
    # @return the browser 'window' object
    #------------------------------------------------------------------------------------

    def window
      @browser.executeJavaScriptAndReturnValue("window")
    end

    #------------------------------------------------------------------------------------
    # @return the browser 'document' object
    #------------------------------------------------------------------------------------

    def document
      @browser.executeJavaScriptAndReturnValue("document")
    end

    #------------------------------------------------------------------------------------
    # @return the browser JSContext
    #------------------------------------------------------------------------------------

    def jscontext
      @browser.getJSContext()
    end
    
    #------------------------------------------------------------------------------------
    # Calls Chrome printing popup interface
    #------------------------------------------------------------------------------------

    def print_page
      @browser.print
    end
    
    #------------------------------------------------------------------------------------
    # Applies javascript method 'instanceOf' defined in ruby_rich.rb to the given object
    # and type.  'instanceOf' is a JSFunction.
    # @param object [JSObject]
    # @param type [String] the type to check
    #------------------------------------------------------------------------------------

    def instanceof(object, type)
      @instanceOf[object, type]
    end
    
    #------------------------------------------------------------------------------------
    # Applies the javascript 'identity' function to the given value.
    # @return [JSObject || primitive] a proxy object or a primitive that does not need to
    # be proxied
    #------------------------------------------------------------------------------------

    def push(value)
      @identity[value]
    end
    
    #------------------------------------------------------------------------------------
    # @param name [String] 
    # @return [JSObject || primitive] the given property from the 'window' scope
    #------------------------------------------------------------------------------------

    def pull(name)
      eval("#{name};")
    end

    #------------------------------------------------------------------------------------
    # Evaluates the javascript script synchronously and then proxies the result in a
    # Ruby JSObject or native ruby object
    # @param scrpt [String] a javascript script to be executed synchronously
    # @return [JSObject || native Ruby object] a JSObject or an Object
    #------------------------------------------------------------------------------------

    def eval(scrpt)
      proxy(@browser.executeJavaScriptAndReturnValue(scrpt))
    end

    #------------------------------------------------------------------------------------
    # Evaluates the javascript script synchronously, but does not pack in JSObject. This
    # method should not be normally called by normal users.  This should be used only in
    # some special cases, usually developers of this application.
    # @param scrpt [String] a javascript script to be executed synchronously
    # @return [java.JSObject] a java.JSObject
    #------------------------------------------------------------------------------------

    def jeval(scrpt)
      @browser.executeJavaScriptAndReturnValue(scrpt)
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def eval_obj(jsobject, prop)
      B.obj = push(jsobject)
      jeval(<<-EOT)
         obj.#{prop}
      EOT
    end
    
    #------------------------------------------------------------------------------------
    # Invokes the function
    # @param scope [Java::JSObject] the object that holds the function, i.e., it´s scope
    # @param function [java JSFunction] the function to be invoked, already in its java
    # form
    # @param *args [Args] a list of java arguments to pass to the function
    # @return jsobject [JSObject] a JSObject or one of its subclasses depending on the
    # result of the function invokation
    # TODO: needs implementation/tests to call functions in the scope of a given object.
    # method_missing in jsobject does create fix the scope, but needs to check if this
    # also needs to be done in this (invoke) method.
    #------------------------------------------------------------------------------------

    def invoke(scope, function, *args)
      # args = nil if (args.size == 1 && args[0].nil?)
      args.shift if args[0].nil?
      proxy(function.invoke(scope, *(args)))
    end

    #------------------------------------------------------------------------------------
    # Duplicates the given Ruby data into a javascript object in the Browser
    # @param name [Symbol, String] the name of the javascript variable into which to dup
    # @param data [Object] a Ruby object
    #------------------------------------------------------------------------------------

    def dup(data)
      push(JSONString.new(data.to_json))
    end
    
    #------------------------------------------------------------------------------------
    # Creates a new function in javascript and returns it as a jsfunction
    # @param symbol [Symbol] the name of the function in javascript namespace.  If not
    # given, then a temporary name is used just to be able to create the function.
    # @return [JSFunction] a jsfunction.
    #------------------------------------------------------------------------------------

    def function(definition)
      eval("var __tmpvar__ = function #{definition}")
      eval("__tmpvar__")
    end

    #------------------------------------------------------------------------------------
    # Creates a Ruby Callback object encapsulating the given block and then generates
    # a javascript callback function that calls the block.  The reason we need the
    # javascript function around the Ruby callback is to be able to set the context,
    # 'this' variable.
    # We first need to inject the block in jxBrowser and the call javascript
    # make_callback that will wrap this object.
    # @param blk [Block] a Ruby Block
    # @return [JSFunction] a javascript function that sets the 'this' variable and
    # calls the given block
    #------------------------------------------------------------------------------------

    def blk2func(blk)
      B.block = Callback.build(blk)
      B.rr.make_callback(nil)
    end
        
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args, &blk)

      name = symbol.id2name
      name.gsub!(/__/,"$")

      if name =~ /(.*)=$/
        assign_window($1, ruby2js(args)[0])
      elsif (((obj = pull(name)).is_a? Sol::JSObject) && obj.function? && args.size > 0)
        obj.send(*args, &blk)
      else
        obj
      end
    end
    
    #------------------------------------------------------------------------------------
    # Converts Ruby arguments into a javascript objects to run in a javascript
    # script.  An
    # IRBObject (Internal Ruby Object) appears when a Ruby Callback is executed and
    # exists for the case that this object transitions between javascript and ends up
    # in a Ruby script.
    # @param args [Array] Ruby array with ruby arguments
    # @return args [Array] Ruby array with ruby arguments converted to javascript
    # arguments
    #------------------------------------------------------------------------------------

    def ruby2js(args)

      args.map do |arg|
        case arg
        when TrueClass, FalseClass, Numeric, String, NilClass, Callback
          arg
        when Sol::IRBObject
          arg
        when Sol::JSObject
          arg.jsvalue
        when Proc
          blk2func(arg).jsvalue
        when Symbol
          raise "Ruby Symbols are not supported in jxBrowser.  Converting ':#{arg}' not supported."
        when Object
          pack(arg)
        else
          raise "This is not a proper argument #{arg}.  Did you use 'proxy' or 'pack'?"
        end
      end
      
    end

    #------------------------------------------------------------------------------------
    # Converts Ruby arguments into a java objects so that they can be used as parameters
    # to a java function call.
    # An
    # IRBObject (Internal Ruby Object) appears when a Ruby Callback is executed and
    # exists for the case that this object transitions between javascript and ends up
    # in a Ruby script.
    # @param args [Array] Ruby array with ruby arguments
    # @return args [Array] Ruby array with ruby arguments converted to java arguments
    #------------------------------------------------------------------------------------

    def ruby2java(args)

      args.map do |arg|
        case arg
        when TrueClass, FalseClass, Numeric, String, NilClass, Callback
          arg.to_java
        when Sol::IRBObject
          arg.to_java
        when Sol::JSObject
          arg.jsvalue.to_java
        when Array, Hash
          pack(arg).to_java
        when Proc
          blk2func(arg).jsvalue.to_java
        when Symbol
          raise "Ruby Symbols are not supported in jxBrowser.  Converting ':#{arg}' not supported."
        else
          arg.to_java
        end
      end
      
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
    #
    #------------------------------------------------------------------------------------

    def save_page
      @browser.saveWebPage("T:\\Rodrigo\\complete.html", "T:\\Rodrigo\\Desenv",
                           Java::ComTeamdevJxbrowserChromium::SavePageType::COMPLETE_HTML)
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
    
    #----------------------------------------------------------------------------------------
    # Pack a ruby object for use inside a javascript script.  A packed ruby object is
    # identical to a proxy object exect by the return value that is a java.JSValue and not
    # a Sol::xxx object.
    # @param obj [Object] The ruby object to be packed
    # @return [java.JSObject] A java.JSObject that that implements the 'run' interface
    #----------------------------------------------------------------------------------------

    def pack(obj)

      case obj
      when TrueClass, FalseClass, Numeric, String, NilClass,
           Java::ComTeamdevJxbrowserChromium::JSValue
        obj
      when Proc
        blk2func(obj).jsvalue
      when Object
        B.obj = Callback.build(obj)
        jeval("new RubyProxy(obj)")
      else
        raise "No method to pack the given object: #{obj}"
      end
      
    end

    #------------------------------------------------------------------------------------
    # Assign the data to the given named window property
    #------------------------------------------------------------------------------------

    def assign_window(property_name, data)
      window.setProperty(property_name, data)
    end

    #------------------------------------------------------------------------------------
    # Private methods
    #------------------------------------------------------------------------------------

    private
    
    #------------------------------------------------------------------------------------
    # Proxies a ruby object into a javascript object.  The javascript object captures
    # all method calls and forwads them to a packed ruby object, by calling method 'run'
    # on this packed object
    # @param obj [Object] The ruby object to be proxied
    # @return [JSObject]
    #------------------------------------------------------------------------------------

    def proxy(obj)

      case obj
      when TrueClass, FalseClass, Numeric, String, NilClass
        obj
      when Java::ComTeamdevJxbrowserChromium::JSValue
        JSObject.build(obj)
      when Proc
        # TODO: Needs to test Proc proxying.  I don´t think the code ever gets here
        blk2func(obj)
      else
        raise "No method to proxy the given object: #{obj}"
      end
      
    end
        
  end
  
end
