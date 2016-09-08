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

class Sol
  
  class Callback
    include Java::ComRbMdarray_sol.RubyCallbackInterface

    attr_reader :ruby_obj
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def initialize(ruby_obj)
      # if ruby_obj is a hash, then make it accessible both by key of by string since
      # javascript does not allow key access
      # ruby_obj = ruby_obj.insensitive if ruby_obj.is_a? Hash
      ruby_obj.extend(InsensitiveHash) if ruby_obj.is_a? Hash
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

    def run(*args)

      # if last argument is a block, i.e., a string between {} then convert this
      # string to a block
      last = args[-1][/^\{(.*?)\}/] if (args.length > 0 && args[-1].is_a?(String))
      # p last
      if last
        args.pop
        blok = (eval  "lambda " + last)
      end

      # convert arguments to 'method' and Ruby args
      method = args.shift
      params = process_args(args)

      res = @ruby_obj.send(method, *params, &blok)
      # p res
      Callback.pack(res)
      
      # Callback.pack(@ruby_obj.send(method, *params, &blok))
      
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

    #----------------------------------------------------------------------------------------
    # Scope can be:
    #  * external: only the received object is packed
    #  * internal: only the internal objects are packed.  In this case, the received object
    #    must respond to the 'each'.
    #  * all: packs both internal and external
    #----------------------------------------------------------------------------------------

    def self.pack(obj, scope: :external)
      
      # Do not pack basic types Boolean, Numberic or String
      case obj
      when TrueClass, FalseClass, Numeric, String, NilClass
        return obj
      end
      
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

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def process_args(args)

      args.map do |arg|
        if (arg.is_a? Java::ComTeamdevJxbrowserChromium::JSObject)
          if (arg.isArray())
            array = []
            for i in 0...arg.length()
              array << arg.get(i)
            end
            process_args(array)
          elsif (arg.isBooleanObject())
            arg.getBooleanValue()
          elsif (arg.isNumberObject())
            arg.getNumberValue()
          elsif (arg.isStringObject())
            arg.getStringValue()
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

