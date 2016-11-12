/******************************************************************************************
 * @author Rodrigo Botafogo
 *
 * Copyright © 2016 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
 * and distribute this software and its documentation, without fee and without a signed 
 * licensing agreement, is hereby granted, provided that the above copyright notice, this 
 * paragraph and the following two paragraphs appear in all copies, modifications, and 
 * distributions.
 *
 * IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
 * INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
 * THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
 * SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
 * RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
 * OR MODIFICATIONS.
 *****************************************************************************************/

/****************************************************************************************
 * Methods to proxy a Ruby Array
 ****************************************************************************************/

function ArrayHandler(ruby_obj) {
  RubyHandler.call(this, ruby_obj);
}

ArrayHandler.prototype = Object.create(RubyHandler.prototype, {
  constructor: {
    configurable: true,
    enumerable: true,
    value: ArrayHandler,
    writable: true
  }
})

ArrayHandler.prototype.get = function(target, property) {
  // if property is not a number then treat it as a function call
  if (isNaN(property)) {
    switch(property) {
    case "length":
      return this.ruby_obj.run("length");
    default:
      // prototype.get packs the results
      res = RubyHandler.prototype.get.call(this, target, property);
    }
    return res;
  } else {
    res = this.ruby_obj.run("[]", parseInt(property));
    if (res instanceof Object && this.ruby_obj.is_instance_of("Sol::IRBObject")) {
      return RubyProxy(this.ruby_obj);
    }
    else {
      return res;
    }
  }
}


