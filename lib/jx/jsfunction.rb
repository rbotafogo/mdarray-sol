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

  attr_writer :scope
  
  class JSFunction < JSObject
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof
      B.push("function")
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

    def send(*args, &blk)

      # if block is given, then create a javascript function that will call the block
      # passing the args
      args.push(blk) if blk
      
      # args need to be processed before invokation converting then to java objects
      B.invoke(@scope, @jsvalue, *(B.ruby2java(args)))
      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def[](*args, &blk)
      send(*args, &blk)
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def _(*args, &blk)

      # if block is given, then create a javascript function that will call the block
      # passing the args
      # args.push(B.blk2func(blk)) if blk
      send(*args, &blk)
      
    end

    #------------------------------------------------------------------------------------
    # Create a new object using this function as a constructor
    #------------------------------------------------------------------------------------

    def new(*args)
      B.rr.new_object(@jsvalue, *args)
    end
    
  end
  
end
