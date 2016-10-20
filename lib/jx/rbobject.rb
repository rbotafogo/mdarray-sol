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
  # RBProxyObject is a Ruby class to Proxy another Ruby class.  Every call to the internal
  # class should go through the external class. 
  ##########################################################################################

  class RBProxyObject

    attr_reader :ruby_obj

    def initialize(ruby_obj)
      @ruby_obj = ruby_obj
    end

    def is_a?(klass)
      @ruby_obj.is_a?(klass)
    end

    def kind_of?(klass)
      @ruby_obj.is_a?(klass)
    end
    
    def method_missing(symbol, *args, &blk)
      begin
        @ruby_obj.send(symbol, *args, &blk)
      rescue TypeError
        args[0].native(symbol, @ruby_obj, &blk)
      end
    end

    def native(*args)
      method = args.shift
      other = args.shift
      other.send(method, @ruby_obj, *args)
    end
    
  end

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

    attr_reader :jsvalue

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(jsvalue)
      @jsvalue = jsvalue
    end

    #------------------------------------------------------------------------------------
    # An IRBObject is called with ruby arguments, so it does not need to call any
    # process_arguments method as it is proxies a Ruby object
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args, &blk)

      # retrieve the 'run' method
      func = @jsvalue.getProperty("run")
      B.invoke(@jsvalue, func, symbol, *args)
      
    end
    
  end
  
  
  ##########################################################################################
  #
  ##########################################################################################

  class RBObject

    attr_reader :jsvalue
    attr_reader :ruby_obj
    attr_reader :native

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(jsvalue, ruby_obj, native)
      @jsvalue = jsvalue
      @ruby_obj = ruby_obj
      @native = native
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof
      B.push("object")
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def method_missing(symbol, *args, &blk)

    end

  end
  
end


