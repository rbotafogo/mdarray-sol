# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
# Copyright © 2015 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
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

#==========================================================================================
# These classes executes in the GUI thread.
#==========================================================================================

class Sol  
  
  #==========================================================================================
  #
  #==========================================================================================

  class Webview
    include Singleton

    attr_reader :webview
    attr_reader :web_engine
    # communication channel (service) to talk to this webview
    attr_reader :comm_channel  
    
    def webview=(webview)
      
      @webview = webview
      @web_engine = @webview.getEngine()
      
      # Load configuration file.  This loads all the Javascript scripts onto the embbeded
      # web browser
      f = Java::JavaIo.File.new("#{File.dirname(__FILE__)}/config.html")
      fil = f.toURI().toURL().toString()
      @web_engine.load(fil)

      # sets the communication between the GUI and the dashboard so that we can add new
      # graphics and visualizations to the Web browser without going through the GUI, i.e,
      # we want to drive the visualization through our Ruby scripts and not directly
      # through the GUI. Creates a GuiCommunication service that will execute in a loop
      # and will wait for messages that should be executed on the Gui thread (JavaFX
      # Application).  In order to actually send a message one needs to use the
      # communication "Bridge" by doing:
      # Bridge.instance.send(<receiver>, :executeScript, <javascript>)
      @comm_channel = GuiCommunication.new
      @comm_channel.set_on_succeeded(ExecMessages.new(@web_engine, @comm_channel))
      
    end

  end
  
  #==========================================================================================
  # Class ExecMessages, executes messages received by the Webview.
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

      @bridge.return_value = receiver.send(method, *args)

      # Notify the @bridge that there is a return_value available
      @bridge.mutex.synchronize {
        @bridge.resource.signal
      }
      
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

# loads the GUI
require_relative 'dcfx'
