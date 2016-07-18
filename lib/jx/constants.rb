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

=begin
$js.load(File.open("#{Sol::js_dir}/dc/node_modules/d3/d3.js"))
$js.load(File.open("#{Sol::js_dir}/dc/node_modules/crossfilter2/crossfilter.js"))
$js.load(File.open("#{Sol::js_dir}/dc/dc.js"))
=end

B = $js
B.freeze

$d3 = B.pull("d3")
$dc = B.pull("dc")

$d3.freeze
$dc.freeze

# Create an arrayChangeHandler for Array proxy building
B.eval(<<-EOT)
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

EOT

B.eval(<<-EOT)

function instanceOf(object, constructor) {
   while (object != null) {
      if (object == constructor.prototype)
         return true;
      if (typeof object == 'xml') {
        return constructor.prototype == XML.prototype;
      }
      object = object.__proto__;
   }
   return false;
}

EOT
