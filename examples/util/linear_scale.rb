# -*- coding: utf-8 -*-

##########################################################################################
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

#=========================================================================================
#
#=========================================================================================

class LinearScale

  attr_reader :scale

  #--------------------------------------------------------------------------------------
  # Create a new linear scale with domain, range
  # @param domain [Array] the domain of the scale
  # @param range [Array] the range of the scale
  #--------------------------------------------------------------------------------------

  def initialize(domain, range)
    @scale = $d3.scale.linear(nil)
    @scale
      .domain(domain)
      .range(range)
  end

  #--------------------------------------------------------------------------------------
  # @scale is a d3 'free' (not inside a chain) function.  In order to call a d3
  # free function we use the '[]' notation
  # @param val [Number] the value to be scaled by this scale
  # @return number [Number] the scaled value
  #--------------------------------------------------------------------------------------

  def[](val)
    @scale[val]
  end

  #--------------------------------------------------------------------------------------
  # Sets the domain of the scale.
  # @param domain [Array] two elements array with the scale domain
  #--------------------------------------------------------------------------------------

  def domain(domain)
    @scale.domain(domain)
  end
  
  #--------------------------------------------------------------------------------------
  # Sets the range of the scale.
  # @param range [Array] two elements array with the scale range
  #--------------------------------------------------------------------------------------

  def range(range)
    @scale.range(range)
  end

  #--------------------------------------------------------------------------------------
  # Updates the domain and range of the scale
  # @param domain [Array] the domain of the scale
  # @param range [Array] the range of the scale
  #--------------------------------------------------------------------------------------

  def update(domain, range)
    @scale.domain(domain)
    @scale.range(range)
  end

end
