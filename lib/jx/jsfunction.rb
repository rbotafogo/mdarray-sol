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

class Sol

  class JSFunction < JSObject
        
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof
      B.eval("'function'")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def function?
      true
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def send(*args)
      # args need to be processed before invokation converting then to JSObjects
      jsend(@scope, @jsvalue, *(B.process_args(args)))
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def[](*args)
      p @scope
      send(*args)
    end
          
    #------------------------------------------------------------------------------------
    # Create a new object using this function as a constructor
    #------------------------------------------------------------------------------------

    def new(*args)

      # assign this function to a temporary variable in javascript
      B.assign_window(:_tmp_func, jsvalue)

      # process every argument and obtain a JSObject or primitive
      params = B.process_args(args)

      # assign every parameter to a variable in javascript
      params.map! do | param |
        var = "sc_#{SecureRandom.hex(8)}"
        B.assign_window(var, param)
        var
      end

      # Call 'new' using the function and the parameter list
      new_func = (params.size > 0)? B.eval("new _tmp_func(#{params.join(',')})") :
                   B.eval("new _tmp_func()")

      # let the garbage collector work
      params.map { | param | B.eval("#{param} = null") }

      new_func
      
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    private
    
    #----------------------------------------------------------------------------------------
    # Push the object into the JS evaluator.  Check to see if this object already has an JS
    # value (jsvar).  The jsvar is just a string of the form sc_xxxxxxxx. This string will be
    # an JS variable that holds the JSObject.  
    #----------------------------------------------------------------------------------------

    def js
      
      if (@jsvar == nil)
        
        # create a new variable name to hold this object inside JS
        @jsvar = "sc_#{SecureRandom.hex(8)}"
        
        # if this object already has a jsobject value then assign to @jsvar the existing
        # jsobject, otherwise, assign itself to @jsvar.  If a jsobject already exists
        # then set the refresh flag to true, so that we know that the jsobject was
        # changed.
        if (@jsvalue.nil?)
          B.assign_window(@jsvar, self)
        else
          @refresh = true
          B.assign_window(@jsvar, @jsvalue)
        end
        
        # Whenever a variable is injected in JS, it is also added to the stack.
        # After eval, every injected variable is removed from JS making sure that we
        # do not have memory leak.
        # Renjin.stack << self
        
      end
      
      @jsvar
      
    end
    
  end
  
end
