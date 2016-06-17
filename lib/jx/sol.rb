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
    Thread.new { RubyRich.launch(@width, @height) }  if !RubyRich.launched?
    # wait for the browser to initialize.  browser should call B.resource.signal
    # after initialization
    B.mutex.synchronize {
      B.resource.wait(B.mutex)
    }
  end
  
end

require_relative 'js'
B = Sol::Js.instance
require_relative 'ruby_rich'

# require_relative 'dashboard'
# require_relative 'callback'

# start the Gui
Sol.start(1300, 500)

# $d3 = B.eval("d3")
# $dc = B.eval("dc")
