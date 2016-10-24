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

require 'json'
require_relative 'jsobject'
require_relative 'rbobject'

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
    attr_accessor :identity
    attr_accessor :instanceOf
        
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

    def typeof(object)
      object.typeof
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
    # Gets the browser JSContext
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
    #------------------------------------------------------------------------------------

    def instanceof(object, type)
      @instanceOf[object, type]
    end
    
    #------------------------------------------------------------------------------------
    # Applies the javascript 'identity' function to the given value.  Returns a
    # packed object
    #------------------------------------------------------------------------------------

    def push(value)
      @identity[value]
    end
    
    #------------------------------------------------------------------------------------
    # Returns the given property from 'window'
    #------------------------------------------------------------------------------------

    def pull(name)
      eval("#{name};")
    end

    #------------------------------------------------------------------------------------
    # packs and object either as a JSObject, RBObject or return it as primitive
    #------------------------------------------------------------------------------------

    def pack(obj, to_ruby: false, scope: document)

      case obj
      when com.teamdev.jxbrowser.chromium.al
        B.obj = Callback.pack(obj)
        RBObject.new(jeval("new RubyProxy(obj)"), obj, true)
      when TrueClass, FalseClass, Numeric, String, NilClass
        obj
      when Java::ComTeamdevJxbrowserChromium::JSValue
        JSObject.build(obj, scope)
      when Sol::Callback
        B.obj = obj
        RBObject.new(jeval("new RubyProxy(obj)"), obj, false)
      when Object
        B.obj = Callback.pack(obj)
        (to_ruby)? RBObject.new(jeval("new RubyProxy(obj)"), obj, true) :
          jeval("new RubyProxy(obj)")
      else
        p "Java::Object"
      end
      
    end

    #------------------------------------------------------------------------------------
    # Proxies the ruby object (obj) into a javascript object.  Return an RBObject.
    #------------------------------------------------------------------------------------

    def proxy(obj)
      pack(obj, to_ruby: true)
    end

    #------------------------------------------------------------------------------------
    # Evaluates the javascript script synchronously and then pack the result in a
    # Ruby JSObject
    # @param scrpt [String] a javascript script to be executed synchronously
    # @return [JSObject] a JSObject or one of its subclasses
    #------------------------------------------------------------------------------------

    def eval(scrpt)
      pack(@browser.executeJavaScriptAndReturnValue(scrpt), to_ruby: true)
    end

    #------------------------------------------------------------------------------------
    # Invokes the function in the scope of object
    # @param object [Java::JSObject] the object that holds the function
    # @param function [java JSFunction] the function to be invoked, already in its java
    # form
    # @param *args [Args] a list of arguments to pass to the function
    # @return jsobject [JSObject] a JSObject or one of its subclasses depending on the
    # result of the function invokation
    #------------------------------------------------------------------------------------

    def invoke(object, function, *args)

      args = nil if (args.size == 1 && args[0].nil?)
      
      if (args)
        # if the argument list has any symbol, convert the symbol to a string
        args.map! { |arg| (arg.is_a? Symbol)? arg.to_s : arg } if !args.nil?
        jargs = []
        args.each { |arg| jargs << arg.to_java }
      end

      pack(function.invoke(object, *(jargs)), to_ruby: false, scope: function)

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
    #
    #------------------------------------------------------------------------------------

    def blk2func(blk)
      B.block = Sol::Callback.new(blk)
      B.rr.make_callback(B.block)
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args, &blk)

      # if block is given, then create a javascript function that will call the block
      # passing the args
      args.push(blk2func(blk)) if (blk)
        
      name = symbol.id2name
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
    # Converts Ruby arguments into a javascript objects to run in a javascript
    # script
    #------------------------------------------------------------------------------------

    def process_args(args)

      args.map do |arg|
        case arg
        when Sol::Callback
          arg
        when Sol::JSObject, Sol::RBObject
          arg.jsvalue
        when Symbol
          arg.to_s
        when Hash, Array
          proxy(arg).jsvalue
        else
          arg
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
    # Returns a list of StyleSheet's
    #------------------------------------------------------------------------------------

    def style_sheets
      eval(<<-EOT)
        var __style_sheets__ = document.styleSheets;
      EOT
      CSSStyleSheets.new
    end
    
    #------------------------------------------------------------------------------------
    # Private methods
    #------------------------------------------------------------------------------------

    private
    
    #------------------------------------------------------------------------------------
    # Assign the data to the given named window property
    #------------------------------------------------------------------------------------

    def assign_window(property_name, data)
      window.setProperty(property_name, data)
    end
        
    #------------------------------------------------------------------------------------
    # Evaluates the javascript script synchronously, but does not pack in JSObject
    # @param scrpt [String] a javascript script to be executed synchronously
    # @return [JSObject] a java.JSObject
    #------------------------------------------------------------------------------------

    def jeval(scrpt)
      @browser.executeJavaScriptAndReturnValue(scrpt)
    end

  end
  
end

=begin
      obj = jscontext.createObject()
      obj.setProperty("constructor", B.Array.jsvalue)
      obj.setProperty("__proto__", B.Array.jsvalue)
      B.c_o = obj
      B.eval(<<-EOT)
        console.log(c_o.constructor === Array);
        console.log(c_o.__proto__ === Array);
        c_o[0] = 10;
        console.log(c_o[0]);
      EOT
=end

=begin      
      if (@identity && !obj.isUndefined() && !eval_obj(obj, "isProxy").isUndefined())
        RBObject.new(obj)
      else
        JSObject.build(obj)
      end
=end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------
=begin
    def jspack(obj, scope: :external)
      pack = "__pack__"
      assign_window(pack, Callback.pack(obj, scope: scope))
      jeval(pack)
    end

    def pr(obj)
      B.probj = obj
      jsobject = jeval(<<-EOT)
        new RubyProxy(probj)
      EOT
    end
=end    
