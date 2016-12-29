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

require_relative 'js_hash'
require_relative 'js_array'

class Sol

  #========================================================================================
  # Class Callback is used for a ruby object to be called from inside a javascript script.
  # When a ruby object is injected into a javascript only public java methods can be
  # called.  For this to work, the Callback class implements the RubyCallbackInterface that
  # defines the run public method.  In order to execute a ruby method, the javascript
  # code needs to call 'run' passing as arguments the method name to be executed in ruby
  # and all its arguments.
  #========================================================================================
  
  class Callback
    include Java::ComRbMdarray_sol.RubyCallbackInterface
    # java_import 'com.teamdev.jxbrowser.chromium.JSAccessible'

    attr_reader :ruby_obj
    attr_reader :this

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def self.build(ruby_obj)

      case ruby_obj
      when Hash
        HashCallback.new(ruby_obj)
      when Array
        ArrayCallback.new(ruby_obj)
      else
        Callback.new(ruby_obj)
      end
        
    end
    
    #----------------------------------------------------------------------------------------
    # @param ruby_obj [Object] a Ruby object, could be any object, in particular we use
    # Array and Hash quite often
    #----------------------------------------------------------------------------------------

    def initialize(ruby_obj)      
      @ruby_obj = ruby_obj
    end

    #----------------------------------------------------------------------------------------
    # NOT REALLY SURE WHY THIS METHOD IS CALLED... COULD GENERATE AN ERROR SOMEWHERE.  NEEDS
    # TO BE FIXED OR AT LEAST UNDERSTOOD!!!
    #----------------------------------------------------------------------------------------

    def default(*args)
      false
    end
    
    #----------------------------------------------------------------------------------------
    # @this is set just before a block is called.  The this argument is the javascript 'this'
    # at the time of calling.
    # @param this [javascript JSObject] the javascript 'this' at the time the block is
    # called
    #----------------------------------------------------------------------------------------

    def set_this(this)
      @this = this
    end
    
    #----------------------------------------------------------------------------------------
    # @param args [Array] the first element of the array is a method to be called on the
    # @ruby_obj variable of this instance.  The other elements are parameters for this
    # method call.  The last argument could be a block.  If it is a string, then we try to
    # convert this string into a block.  This method is called from javascript, so all
    # args are javascript args and need to be converted to Ruby args for the method to
    # run
    # @return a packed js o
    #----------------------------------------------------------------------------------------

    def run(*args)
      
      # first argument is the 'method' name 
      method = args.shift
      
      # try to convert last argument to block if it is a String.  If fails to convert
      # the String to a block, then leave the string untouched as the last argument.
      if ((last = args[-1]).is_a? String)
        args.pop
        begin
          blok = (eval "lambda " + last)
        rescue
          blok = nil
          args << last
        end
      end

      # convert all remaining arguments to Ruby 
      params = Callback.process_args(args)

      case @ruby_obj
      when Proc
        B.pack(instance_exec(*params, &(@ruby_obj)))
      else
        B.pack(@ruby_obj.send(method, *params, &blok))
      end
      
    end
    
    #----------------------------------------------------------------------------------------
    # Checks if the ruby_obj is an instance of the given class
    # @param class_name [String] the name of a ruby class
    # @return boolean [Boolean] true or false
    #----------------------------------------------------------------------------------------

    def is_instance_of(class_name)
      klass = Object.const_get(class_name)
      @ruby_obj.instance_of? klass
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def get_class(class_name)
      Callback.pack(send("const_get", class_name))
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def build(class_name, *args)
      raise "#{class_name} #{args}"
      klass = get_class(class_name)
      klass.send("new", *args)
    end

    #------------------------------------------------------------------------------------
    # Converts given arguments into Ruby arguments
    # @param args [Array] array of javascript arguments to be converted into ruby
    # arguments to be given to @ruby_obj.
    #------------------------------------------------------------------------------------

    def self.process_args(args)

      collect = []

      args.each do |arg|
        if (arg.is_a? Java::ComTeamdevJxbrowserChromium::JSValue)
          collect << Callback.process_arg(arg)
        else
          collect << arg
        end
      end
      
      collect
      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    private
    
    #------------------------------------------------------------------------------------
    # Converts given argument into Ruby argument.
    # @param arg [jsvalue] A javascript value that needs to be converted to a ruby
    # object for processing by the 'run' method.
    # @return [Sol::JSObject || Sol::IRBObject] The jsvalue wrapped into a ruby object
    # if the jsvalue is actually a proxied ruby object, then wrapp it in an IRBObject
    # otherwise wrapp it into a JSObject.  
    #------------------------------------------------------------------------------------

    def self.process_arg(arg)
      (B.eval_obj(arg, "isProxy").isUndefined())?
        JSObject.build(arg) : IRBObject.new(B.eval_obj(arg, "ruby_obj"))
    end
    
  end

  #=======================================================================================
  #
  #=======================================================================================
  
  class ArrayCallback < Callback

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(ruby_obj)
      ruby_obj.extend(JSArrayInterface)
      super(ruby_obj)
    end
    
    #----------------------------------------------------------------------------------------
    # @return a packed js object
    #----------------------------------------------------------------------------------------

    def get(index)
      B.pack(@ruby_obj.send('[]', index))
    end

  end

  #=======================================================================================
  #
  #=======================================================================================
  
  class HashCallback < Callback

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(ruby_obj)
      ruby_obj.extend(InsensitiveHash)
      super(ruby_obj)
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def get_key(key)
      B.pack(@ruby_obj.send('[]', key))
    end
    
  end
  
end


