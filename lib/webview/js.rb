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

class Sol

  class JSObject

    attr_reader :jsobject

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(jsobject)
      @jsobject = jsobject
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args)
      name = symbol.id2name
      @jsobject.getMember(name)
    end
    
  end
  
  #==========================================================================================
  # Class to communicate with the embedded browser (Webview), by sending javascript
  # messages
  #==========================================================================================

  class Js
    include Singleton

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

      # if the return value is a Webview JSObject then wrap it in a Ruby JSObject
      if (@bridge.return_value.is_a? Java::ComSunWebkitDom::JSObject)
        JSObject.new(@bridge.return_value)
      else
        @bridge.return_value
      end
      
    end
    
  end
  


  #==========================================================================================
  # This class executes in another thread than the GUI thread.  Communication between the
  # Dashboard and the GUI (WebView) is done through the Bridge class.
  #==========================================================================================
  
  class JS

    attr_reader :bridge           # communication channel
    
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
      @bridge.send(:gui, :executeScript, scrpt)
      p @bridge.return_value
    end

    #------------------------------------------------------------------------------------
    # Deletes all divs from the Browser
    #------------------------------------------------------------------------------------

    def delete_all
      eval(<<-EOS)
        d3.selectAll(\"div\").remove();
      EOS
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

B = Sol::Js.instance

