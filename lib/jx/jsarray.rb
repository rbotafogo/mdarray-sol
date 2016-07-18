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

  #==========================================================================================
  # 
  #==========================================================================================
  
  class ProxyArray < JSObject

    attr_reader :ruby_array  # this is the ruby array that will be proxied

    #------------------------------------------------------------------------------------
    # Gets a ruby array and proxy it in javascript so that it becomes the storage
    # medium for the array
    #------------------------------------------------------------------------------------

    def initialize(array)
      
      @ruby_array = array
      @jsvar = nil
      @refresh = false
      
      js
      proxy_array(@jsvar)
      
    end
    
    #------------------------------------------------------------------------------------
    # Gets a ruby array and proxy it in javascript so that it becomes the storage
    # medium for the array
    #------------------------------------------------------------------------------------

    def proxy_array(name)
      
      B.eval(<<-EOF)
        var arrayChangeHandler = {
          get: function(target, property) {
                 console.log('getting ' + property + ' for ' + target);
               // property is index in this case
                 return target[property];
               },
          set: function(target, property, value, receiver) {
                 console.log('setting ' + property + ' for ' + target + ' with value ' + value);
                 target[property] = value;
                 // you have to return true to accept the changes
                 return true;
               }
         };

      EOF

      B.eval(<<-EOF)
         var #{name} = new Proxy([], arrayChangeHandler);

         #{name}.push('Test');
         console.log(#{name}[0]);

      EOF

    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def typeof
      return "array"
    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def array?
      true
    end

  end
  
  #==========================================================================================
  # 
  #==========================================================================================

  class JSArray < JSObject

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def array?
      true
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def get(index)
      JSObject.build(@jsvalue.get(index))
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def [](index)
      get(index)
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def length
      @jsvalue.length
    end
    
  end

end
