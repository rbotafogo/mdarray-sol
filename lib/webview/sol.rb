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

  def self.js
    return JS.new
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.add_data(js_variable, data)
    Bridge.instance.send(:window, :setMember, js_variable, data)
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.start(width, height)
    @width = width
    @height = height
    Thread.new { DCFX.launch(@width, @height) }  if !DCFX.launched?
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

    #------------------------------------------------------------------------------------
    # Use a LinkedBlockingQueue with max size of 1 to communicate from the ruby script
    # to the GUI.  The ruby script will send a message that is consumed by the GUI.
    #------------------------------------------------------------------------------------
    
    def initialize
      @queue = java.util.concurrent::LinkedBlockingQueue.new(1)
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
  # This class executes a given message in the GUI thread.
  #==========================================================================================
  
  class ExecMessages
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
      else
        raise "Unknown message receiver #{receiver}"
      end
      
      receiver.send(method, *args)
      @service.restart()
      
    end

  end

  #==========================================================================================
  #
  #==========================================================================================
  
  class ReadBuffer < javafx.concurrent.Task
    
    def initialize
      @bridge = Bridge.instance
    end
    
    #----------------------------------------------------------------------------------------
    # 
    #----------------------------------------------------------------------------------------
    
    def call
      begin
        msg = @bridge.take
        return msg                             # this is the returned message to the handle
      rescue java.lang.InterruptedException => e
        if (is_cancelled)
          updateMessage("Cancelled")
        end
      end
      
    end
    
  end
      
  #==========================================================================================
  # A Service is a non-visual component encapsulating the information required to perform
  # some work on one or more background threads. As part of the JavaFX UI library, the
  # Service knows about the JavaFX Application thread and is designed to relieve the
  # application developer from the burden of manging multithreaded code that interacts
  # with the user interface. As such, all of the methods and state on the Service are
  # intended to be invoked exclusively from the JavaFX Application thread.
  #
  # Service implements Worker. As such, you can observe the state of the background
  # operation and optionally cancel it. Service is a reusable Worker, meaning that it can
  # be reset and restarted. Due to this, a Service can be constructed declaratively and
  # restarted on demand.
  # 
  # If an Executor is specified on the Service, then it will be used to actually execute
  # the service. Otherwise, a daemon thread will be created and executed. If you wish to
  # create non-daemon threads, then specify a custom Executor (for example, you could use
  # a ThreadPoolExecutor with a custom ThreadFactory).
  #
  # Because a Service is intended to simplify declarative use cases, subclasses should
  # expose as properties the input parameters to the work to be done. For example,
  # suppose I wanted to write a Service which read the first line from any URL and
  # returned it as a String. Such a Service might be defined, such that it had a single
  # property, url.
  #
  # GuiCommunication establishes a communication channel from the ruby script and the
  # JavaFX Application.
  #==========================================================================================

  class GuiCommunication < javafx.concurrent.Service
    
    def createTask
      ReadBuffer.new
    end
    
  end

end

require_relative 'dcfx'
require_relative 'dashboard'
require_relative 'js'

# start the Gui
Sol.start(1300, 500)
