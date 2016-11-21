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

class Sol

  ##########################################################################################
  # An IRBObject is an "Internal" Ruby Object, i.e., is is created while executing a
  # callback method that returns a Ruby Object and it stays inside a javascript script.
  # This happens when a ruby block is passed as argument to a javascript function that
  # expects a function as parameter. The block is converted to a javascript function
  # in ruby_rich.rb by the call to:
  #   // Makes a callback function from a given Ruby block
  #   this.make_callback = function(blk) {
  #     return function (...args) { blk.set_this(this); return blk.run("call", ...args); }
  #   }
  # When this function is called, blk.run is called, which call Callback.run.  In
  # Callback.run the arguments are converted to ruby arguments.  If the block returns
  # a ruby Object, this Object is packed in a IRBObject.
  ##########################################################################################
  
  class IRBObject
    include Java::ComRbMdarray_sol.RubyCallbackInterface

    attr_reader :jsvalue
    attr_reader :ruby_obj
    
    #------------------------------------------------------------------------------------
    # Undefine methods so that they are caught by method_missing and send to the
    # actual object
    #------------------------------------------------------------------------------------

    undef :instance_variable_defined?
    undef :instance_variable_get
    undef :instance_variable_set
    undef :instance_variables
    undef :method
    undef :methods
    undef :private_methods
    undef :protected_methods
    undef :public_method
    undef :public_methods
    undef :public_send
    undef :remove_instance_variable
    undef :respond_to?
    undef :respond_to_missing?
    undef :singleton_methods
    undef :taint
    undef :tainted?
    undef :tap
    undef :to_enum
    undef :to_s
    undef :trust
    undef :untaint
    undef :untrust
    undef :untrusted?    
    # undef :singleton_method

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(jsvalue)
      @jsvalue = jsvalue
      @run_func = @jsvalue.getProperty("run")
      @ruby_obj = @jsvalue.asJavaObject().ruby_obj
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def is_instance_of(class_name)
      B.invoke(@jsvalue, @run_func, "is_instance_of", class_name)
    end

    #------------------------------------------------------------------------------------
    # An IRBObject is called with ruby arguments, so it does not need to call any
    # process_arguments method as it is proxies a Ruby object
    # TODO: Might actually need to process_args on the argument since we use invoke
    # BUG!!!
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args, &blk)
      # B.invoke(@jsvalue, @run_func, symbol, *args)
      @ruby_obj.send(symbol, *args, &blk)
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def native(*args)
      p "IRBObject native method.  NOT WORKING YET!!"
      method = args.shift
      # other is a ruby object
      other = args.shift
    end

  end

end
