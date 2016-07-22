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
      # if any of the args is a JSObject, then we need to treat it in another way, as
      # invoke is defined only for java objects

      args.map! { |x| (x.is_a? Sol::JSObject)? x.jsvalue : x }
      JSObject.build(@jsvalue.invoke(B.document, *args))

=begin
      p args
      par = process_args(*args)
      p par
      JSObject.build(@jsvalue.invoke(B.document, *process_args(args)))
=end      
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def[](*args)
      send(*args)
    end
          
    #------------------------------------------------------------------------------------
    # Create a new object using this function as a constructor
    #------------------------------------------------------------------------------------

    def new(*args)
      p "new #{jsvar}(\"#{args.join(',')}\")"
      B.eval("new #{jsvar}(\"#{args.join(',')}\")")
    end
    
  end
  
end
