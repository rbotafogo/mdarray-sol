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
  
  class Callback
    include Java::ComRbMdarray_sol.RubyCallbackInterface
    
    attr_reader :ruby_obj
    attr_reader :this
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def initialize(ruby_obj)

      # if ruby_obj is a hash, then make it accessible both by key or by string since
      # javascript does not allow key access
      case ruby_obj
      when Hash
        ruby_obj.extend(InsensitiveHash)
      when Array
        ruby_obj.extend(JSArrayInterface)
      end

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
    #
    #----------------------------------------------------------------------------------------

    def set_this(this)
      @this = this
    end

    #----------------------------------------------------------------------------------------
    # 
    #----------------------------------------------------------------------------------------

    def run(*args)

      # first argument is the 'method' name 
      method = args.shift
      
      # try to convert last argument to block
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

      if (@ruby_obj.is_a? Proc)
        B.pack(instance_exec(*params, &(@ruby_obj)), to_ruby: false)
      else
        B.pack(@ruby_obj.send(method, *params, &blok), to_ruby: false)
        
      end
      
    end
    
    #----------------------------------------------------------------------------------------
    # Scope can be:
    #  * external: only the received object is packed
    #  * internal: only the internal objects are packed.  In this case, the received object
    #    must respond to the 'each'.
    #  * all: packs both internal and external
    #----------------------------------------------------------------------------------------

    def self.pack(obj, scope: :external)
      
      case scope
      when :internal
        raise "Cannot jspack object's internals as it does not respond to the :each method." if
          !obj.respond_to?(:each)
        obj.map { |pk| Callback.new(pk) }
      when :external
        Callback.new(obj)
      when :all
        # if we can go inside the obj with 'map!' then do it, otherwise, just pack the
        # external object. CHECK method 'each', 'map' and 'map!'
        (obj.respond_to? :map!)? Callback.new(obj.map! { |pk| Callback.pack(pk) }) :
          Callback.new(obj)
      else
        raise "Scope must be :internal, :external or :all.  Unknown #{scope} scope"
      end
      
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def is_instance_of(class_name)
      klass = Object.const_get(class_name)
      @ruby_obj.instance_of? klass
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def isCallback
      true
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
    #------------------------------------------------------------------------------------

    def self.process_args(args)

      args.map do |arg|
        if (arg.is_a? Java::ComTeamdevJxbrowserChromium::JSObject)
          # If arg is an JSArray, then from the point of view of Ruby we need to
          # break this array in all its individual elements, otherwise Ruby will see
          # only one single argument instead of an array of arguments
          if (arg.isArray())
            array = []
            for i in 0...arg.length()
              array << Callback.process_args(arg.get(i))
            end
            # process_args(array)
          elsif (arg.isBooleanObject())
            arg.getBooleanValue()
          elsif (arg.isNumberObject())
            arg.getNumberValue()
          elsif (arg.isStringObject())
            arg.getStringValue()
          else
            (B.eval_obj(arg, "isProxy").getValue())?
              IRBObject.new(B.eval_obj(arg, "ruby_obj")) : JSObject.build(arg)
          end
        elsif (arg.is_a? Java::ComTeamdevJxbrowserChromium::JSValue)
          if (arg.isBoolean())
            arg.getBooleanValue()
          elsif (arg.isNumber())
            arg.getNumberValue()
          elsif (arg.isString())
            arg.getStringValue()
          else
            raise "Illegal argument #{arg}"
          end
        else
          arg
        end
        
      end
      
    end
    
  end
  
end

