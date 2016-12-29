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
* Methods to proxy a Ruby Hash
****************************************************************************************/

function HashHandler(ruby_obj) {
  RubyHandler.call(this, ruby_obj);
}

HashHandler.prototype = Object.create(RubyHandler.prototype, {
  constructor: {
    configurable: true,
    enumerable: true,
    value: HashHandler,
    writable: true
  }  
})

HashHandler.prototype.get = function(target, property) {

  // check to see if 'property' is a hash value
  if ((res = this.ruby_obj.get_key(property)) != null)
    return res;

  switch(property) {
  case "isProxy":
    return true
  case "ruby_obj":
    return this.ruby_obj;
  }

  if (this.ruby_obj.run("respond_to?", property))
    return RubyHandler.prototype.get.call(this, target, property);
}

HashHandler.prototype.set = function(target, property, value, receiver) {
  if (this.ruby_obj.run("respond_to?", property)) {
    return RubyHandler.prototype.set.call(this, target, property, value, receiver);
  } else {
    return this.ruby_obj.run("[]=", property, value);
  }
}

HashHandler.prototype.getOwnPropertyDescriptor = function(target, property) {
  var res = this.ruby_obj.run("[]", property);
  return { configurable: true, enumerable:true, value: res };
}

HashHandler.prototype.ownKeys = function(target) {
  return this.ruby_obj.run("keys");
}

/*
HashHandler.prototype.has = function(target, property) {
  return this.ruby_obj.run("respond_to?", property)
}

HashHandler.prototype.isExtensible = function(target) {
  console.log("Method isExtensible in file hash_handler.js");
  return false;
}

HashHandler.prototype.preventExtensions = function(target) {
  console.log("Method preventExtensions in file hash_handler.js");
  return true;
}
*/
