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
  #
  ##########################################################################################

  class RBObject

    attr_reader :jsvalue
    attr_reader :ruby_obj
    attr_reader :native

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

      p @ruby_obj
      p symbol
      p args
      p blk
      
      begin
        @ruby_obj.send(symbol, *args, &blk)
      rescue TypeError
        args[0].native(symbol, @ruby_obj, &blk)
      end

    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def native(*args)
      method = args.shift
      other = args.shift
      other.send(method, @ruby_obj, *args)
    end

  end
  
end
