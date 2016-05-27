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

require_relative 'dcfx'
require_relative 'dashboard'

#==========================================================================================
#
#==========================================================================================

class Sol

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------
  
  def self.camelcase(str, *separators)
    
    case separators.first
      
    when Symbol, TrueClass, FalseClass, NilClass
      first_letter = separators.shift
    end
    
    separators = ['_', '\s'] if separators.empty?
    
    # str = self.dup
    
    separators.each do |s|
      str = str.gsub(/(?:#{s}+)([a-z])/){ $1.upcase }
    end
    
    case first_letter
    when :upper, true
      str = str.gsub(/(\A|\s)([a-z])/){ $1 + $2.upcase }
    when :lower, false
      str = str.gsub(/(\A|\s)([A-Z])/){ $1 + $2.downcase }
    end
    
    str
    
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.dashboard(name, data, dimension_labels, date_columns = [])
    return Dashboard.new(name, data, dimension_labels, date_columns)
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.eval(scrpt)
    Bridge.instance.send(:gui, :executeScript, scrpt)
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.add_data(js_variable, data)
    Bridge.instance.send(:window, :setMember, js_variable, data)
  end

  #------------------------------------------------------------------------------------
  # Remove everything from the GUI
  #------------------------------------------------------------------------------------

  def self.delete_all

    eval(<<-EOS)
      d3.selectAll(\"div\").remove();
    EOS
    
  end

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
    attr_reader :cv               # conditional variable
    attr_reader :mutex            # mutex

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------
    
    def initialize
      @queue = java.util.concurrent::LinkedBlockingQueue.new(1)
      @cv = ConditionVariable.new
      @mutex = Mutex.new
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def send(*message)
      @queue.put(message)
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def take
      @queue.take()
    end
    
  end
  
  #==========================================================================================
  #
  #==========================================================================================
  
  class MyTask < javafx.concurrent.Task
    
    def initialize
      @bridge = Bridge.instance
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def call
      begin
        msg = @bridge.take
        # p msg
        return msg                             # this is the returned message to the handle
      rescue java.lang.InterruptedException => e
        if (is_cancelled)
          updateMessage("Cancelled")
        end
      end
      
    end
    
  end
  
  #==========================================================================================
  # This class executes in the GUI thread.
  #==========================================================================================
  
  class MyHandle
    include javafx.event.EventHandler
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def initialize(web_engine, service)
      
      @web_engine = web_engine
      @service = service
      
      @window = @web_engine.executeScript("window")
      @document = @window.eval("document")
      @web_engine.setJavaScriptEnabled(true)
      @bridge = Bridge.instance
      
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def handle(event)
      
      receiver, method, *args = event.getSource().getValue()
      
      case receiver
      when :gui
        receiver = @web_engine
      when :window
        receiver = @window
      end
      
      receiver.send(method, *args)
      
      @bridge.mutex.synchronize {
        @bridge.cv.signal
      }
      
      @service.restart()
      
    end

  end
    
  #==========================================================================================
  #
  #==========================================================================================

  class MyService < javafx.concurrent.Service
    
    def createTask
      MyTask.new
    end
    
  end

end
