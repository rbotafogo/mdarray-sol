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
  # This is JRubyFX application.
  #==========================================================================================

  class RubyRich < JRubyFX::Application
    java_import com.teamdev.jxbrowser.chromium.Browser
    java_import com.teamdev.jxbrowser.chromium.javafx.BrowserView
    
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

      # Create the singleton Webview with the webview instance variable as a pointer
      # to a javaFX WebView
      # Webview.instance.webview = WebView.new
      # webview = Webview.instance.webview
      # web_engine = Webview.instance.web_engine
      # comm_channel = Webview.instance.comm_channel

      browser = Browser.new;
      browser_view = BrowserView.new(browser);
      B.browser = browser
      
      #--------------------------------------------------------------------------------------
      # User Interface
      #--------------------------------------------------------------------------------------
      
      with(stage, title: "Ruby Rich Client Interface - RubyRich") do
        Platform.set_implicit_exit(false)
        layout_scene(RubyRich.width, RubyRich.height, :oldlace) do
          pane = border_pane do
            top menu_bar 
            center browser_view
          end
        end
        set_on_close_request do
          stage.close
        end
        show
      end

      B.resource.signal
        
    end
    
    #----------------------------------------------------------------------------------------
    # Checks to see if DCFX was already launched.  For some reason a JavaFX application
    # can only be launched once.
    #----------------------------------------------------------------------------------------
    
    def self.launched?
      (RubyRich.launched)? true : false
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def self.launch(width, height)
      RubyRich.launched = true
      RubyRich.width = width
      RubyRich.height = height
      super()
    end
    
  end
  
end

