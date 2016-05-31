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


class Sol  
  
  #==========================================================================================
  # This is the GUI thread.  It is the mais JRubyFX application.
  #==========================================================================================

  class DCFX < JRubyFX::Application
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    class << self
      
      attr_accessor :dashboard
      attr_accessor :width
      attr_accessor :height
      attr_accessor :launched
      
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def start(stage)
      
      browser = WebView.new
      @web_engine = browser.getEngine()
      
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
      service = GuiCommunication.new
      service.set_on_succeeded(ExecMessages.new(@web_engine, service))
      
      #--------------------------------------------------------------------------------------
      # User Interface
      #--------------------------------------------------------------------------------------
      
      # Add button to run the script. Later should be removed as the graph is supposed to 
      # run when the window is loaded
      # script_button = build(Button, "Run script")
      # script_button.set_on_action { |e| plot }
      
      
      # Example on how to: Add a menu bar -- do not delete (yet!)
      # menu_bar = build(MenuBar)
      # menu_filters = build(Menu, "Filters")
      # add filters to the filter menu
      # add_filters
      # menu_bar.get_menus.add_all(menu_filters)
      
      @web_engine.getLoadWorker().stateProperty().
        addListener(ChangeListener.impl do |ov, old_state, new_state|
                      service.start()
                    end)
      
      with(stage, title: "Sol Charting Library (based on DC.js)") do
        Platform.set_implicit_exit(false)
        layout_scene(DCFX.width, DCFX.height, :oldlace) do
          pane = border_pane do
            top menu_bar 
            center browser
            # right script_button
          end
        end
        set_on_close_request do
          stage.close
        end
        show
      end
      
=begin
        @web_engine.set_on_status_changed { |e| p e.toString() }
        @web_engine.set_on_alert { |e| p e.toString() }
        @web_engine.set_on_resized { |e| p e.toString() }
        @web_engine.set_on_visibility_changed { |e| p e.toString() }
        browser.set_on_mouse_entered { |e| p e.toString() }
=end

    end
    
    #----------------------------------------------------------------------------------------
    # Checks to see if DCFX was already launched.  For some reason a JavaFX application
    # can only be launched once.
    #----------------------------------------------------------------------------------------
    
    def self.launched?
      (DCFX.launched)? true : false
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    # def self.launch(dashboard, width, height)
    def self.launch(width, height)
      DCFX.launched = true
      DCFX.width = width
      DCFX.height = height
      super()
    end
    
  end
  
end

