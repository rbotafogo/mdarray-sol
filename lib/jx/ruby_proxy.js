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
* RubyProxy proxies a Ruby Object into a javascript object
* ruby_obj is a jspacked ruby object
*****************************************************************************************/

function RubyProxy(ruby_obj) {
  if (ruby_obj.is_instance_of("InsensitiveHash")) {
    this.proxy = new Proxy({}, new HashHandler(ruby_obj));
  } else if (ruby_obj.is_instance_of("Array")) {
    ;
  } else if (ruby_obj.is_instance_of("MDArray")) {
    ;
  } else {
    this.proxy = new Proxy({}, new RubyHandler(ruby_obj));
  }
  return this.proxy;
}

function RubyHandler(ruby_obj) {
  this.ruby_obj = ruby_obj;
}

RubyHandler.prototype = {

  set: function(target, property, value, receiver) {
    console.log("my ruby_obj is ");
  },
  
  apply: function(target, thisArg, argumentsList) {
    console.log("called: " + argumentsList.join(", "));
    return argumentsList[0] + argumentsList[1] + argumentsList[2];
  },
  
  // THINK what should be done with this
  getPrototypeOf: function(target) {
    console.log("getPrototypeOf")
    return false;
  },
  
  setPrototypeOf: function(target, newProto) {
    console.log("setPrototypeOf")
    return false;
  },
  
  get: function(target, property) {
    ruby_obj = this.ruby_obj;
    return function(...params) {
      if(params.length > 0 && typeof params[params.length - 1] === "function") {
	temp_func = params.pop();
	var blk = "{ |*args| B.temp_func(*args) }";
	params.push(blk);
      }
      switch (params.length) {
      case 0:
	return ruby_obj.run(property);
	break;
      case 1:
	return ruby_obj.run(property, params[0]);
	break;
      case 2:
	return ruby_obj.run(property, params[0], params[1]);
	break;
      case 3:
	return ruby_obj.run(property, params[0], params[1], params[2]);
	break;
      case 4:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3]);
	break;
      case 5:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4]);
	break;
      case 6:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5]);
	break;
      case 7:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6]);
	break;
      case 8:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7]);
	break;
      case 9:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8]);
	break;
      case 10:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9]);
	break;
      case 11:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10]);
	break;
      case 12:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10],
			    params[11]);
	break;
      case 13:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10],
			    params[11], params[12]);
	break;
      case 14:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10],
			    params[11], params[12], params[13]);
	break;
      case 15:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10],
			    params[11], params[12], params[13], params[14]);
	break;
      }
    }
  }
}

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
  var res = this.ruby_obj.run("[]", property);
  if ( res != null) {
    return res;
  } else {
    return RubyHandler.prototype.get.call(this, target, property);
  }
}

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
  if (isNaN(property)) {
    return RubyHandler.prototype.get.call(this, target, property);
  } else {
    return ruby_obj.run("[]", parseInt(property));
  }
}

