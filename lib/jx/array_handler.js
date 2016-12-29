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
    case "isProxy":
      return true
    case "ruby_obj":
      return this.ruby_obj;
    default:
      // prototype.get proxies the results
      return RubyHandler.prototype.get.call(this, target, property);
    }
  } else {
    // return this.ruby_obj.run("[]", parseInt(property));
    return this.ruby_obj.get(parseInt(property));
  }
}

/* sets the value of property */
ArrayHandler.prototype.set = function(target, property, value, receiver) {
  this.ruby_obj.run("[]=", parseInt(property), value);
}

/*
// Method defineProperty is called after method set, if method set fails
ArrayHandler.prototype.defineProperty = function(target, property, descriptor) {
  return this.ruby_obj.run("[]=", parseInt(property), descriptor.value);
}
*/
