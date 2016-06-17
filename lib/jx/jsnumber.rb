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

  class JSNumber < JSObject

    # Returns Byte presentation of the current number value.
    def byte
      @jsvalue.getByte
    end

    # Returns Double presentation of the current number value.
    def double
      @jsvalue.getDouble()
    end

    # Returns Float presentation of the current number value.
    def Float
      @jsvalue.getFloat()
    end

    #  Returns Integer presentation of the current number value.
    def int
      @jsvalue.getInteger()
    end

    # Returns Long presentation of the current number value.
    def long
      @jsvalue.getLong()
    end

    # Returns number value of the current JavaScript object if object
    # represents a primitive number or Number object, otherwise throws
    # IllegalStateException.
    def number_value
      @jsvalue.getNumberValue()
    end

    # Returns Short presentation of the current number value.
    def short
      @jsvalue.getShort()
    end

    # Returns the value of the current primitive instance.
    def value
      @jsvalue.getValue()
    end

  end

end
