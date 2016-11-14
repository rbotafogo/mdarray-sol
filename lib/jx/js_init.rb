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

B = $js

B.load("ruby_rich.js")
B.load("ruby_proxy.js")
B.load("hash_handler.js")
B.load("array_handler.js")

B.identity = Sol::JSObject.build(
  B.browser.executeJavaScriptAndReturnValue(<<-EOT)
    rr.identity  
  EOT
)

B.instanceOf = Sol::JSObject.build(
  B.browser.executeJavaScriptAndReturnValue(<<-EOT)
    rr.instanceOf  
  EOT
)

B.freeze

module ObjectExtension

  def extend_by_name(obj, module_name)
    mdl = Object.const_get(module_name)
    obj.run("extend", mdl)
  end
  
end

$robject = B.proxy(Object.new)
$robject.extend(ObjectExtension)
B.robject = $robject

$d3 = B.pull("d3")
$dc = B.pull("dc")

$d3.freeze
$dc.freeze
