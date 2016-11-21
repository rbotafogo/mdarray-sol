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


module InsensitiveHash

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------
      
  def is_instance_of(class_name)
    klass = Object.const_get(class_name)
    instance_of? klass
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def [](key)
    super(key)
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def fetch(key, to_sym = true)
    (to_sym)? super(key.to_sym) : super(key)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def assoc(key, to_sym = false)
    (to_sym)? super(key.to_sym) : super(key)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def []=(key, value)
    super(key, value)
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def store(key, value, to_sym = true)
    (to_sym)? super(key.to_sym, value) : super(key, value)
  end

end
