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
require_relative 'jsobject'

class Sol
  
  #==========================================================================================
  # Class to communicate with the embedded browser (Webview), by sending javascript
  # messages
  #==========================================================================================

  class Js
    include Singleton

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

    def initialize
      @bridge = Bridge.instance
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def eval(scrpt)

      # p scrpt
      @bridge.send(:gui, :executeScript, scrpt)
      
      # if the return value is a Webview JSObject then wrap it in a Ruby JSObject
      if (@bridge.return_value.is_a? Java::ComSunWebkitDom::JSObject)
        JSObject.new(@bridge.return_value)
      else
        @bridge.return_value
      end
      
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def assign(name, data)
      @bridge.send(:window, :setMember, name, data)      
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
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------
  
  private
  
  #==========================================================================================
  # Bridge is the communication channel between the Dashboard, where all Ruby code is
  # written and executed and the GUI (Web Browser).  The Dashboard thread and the GUI
  # thread need to communicate through message passing.  The Dashboard cannot directly
  # interfere with the GUI thread.
  #==========================================================================================

  class Bridge
    include Singleton

    attr_reader :queue            # comunication queue
    
    attr_reader :mutex
    attr_reader :resource
    attr_accessor :return_value     # value returned after the message is executed

    #------------------------------------------------------------------------------------
    # Use a LinkedBlockingQueue with max size of 1 to communicate from the ruby script
    # to the GUI.  The ruby script will send a message that is consumed by the GUI.
    # When a message is send, the thread needs to wait for the GUI to process the
    # message in order to get the return value.  We use a mutex and a condition
    # variable for synchronization between the bridge and the Webview.
    #------------------------------------------------------------------------------------
    
    def initialize
      @queue = java.util.concurrent::LinkedBlockingQueue.new(1)
      @return_value = nil
      
      @mutex = Mutex.new
      @resource = ConditionVariable.new
    end

    #------------------------------------------------------------------------------------
    # Synchronized send message.  Waits for the return_value to be available.
    #------------------------------------------------------------------------------------

    def send(*message)
      @queue.put(message)
      
      # wait for return_value.  Suspend the current thread. This will be released
      # when the return_value is filled in method 'handle' in webview
      @mutex.synchronize {
        @resource.wait(@mutex)
      }
      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def take
      @queue.take()
    end
    
  end
  
end

