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
  if (ruby_obj.is_instance_of("Sol::IRBObject")) {
    if (ruby_obj.run("is_instance_of", "Array")) {
      this.proxy = new Proxy([], new ArrayHandler(ruby_obj));
    } else if (ruby_obj.run("is_instance_of", "Hash")) {
      this.proxy = new Proxy({}, new HashHandler(ruby_obj));
    }
  } else if (ruby_obj.is_instance_of("Array")) {
    this.proxy = new Proxy([], new ArrayHandler(ruby_obj));
  } else if (ruby_obj.is_instance_of("Hash")) {
    this.proxy = new Proxy({}, new HashHandler(ruby_obj));
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

  /*
  ownKeys: function(target) {
    console.log("ownKeys");
    console.log(rr.proxy_array);
    return rr.proxy_array;
  },*/

  // TODO: This is propably not correct.  Check!!
  defineProperty: function(target, property, descriptor) {
    console.log("defineProperty");
    console.log(property);
    console.log(descriptor);
    return this.ruby_obj.run("[]=", property, descriptor.value);
  },
  
  getOwnPropertyDescriptor: function(target, descriptor) {
    return this.proxy;
  },
  
  /* sets the value of property */
  set: function(target, property, value, receiver) {
    this.ruby_obj.run(property, value);
  },

  has: function(target, property) {
    return this.ruby_obj.run("respond_to?", property);
  },

  isExtensible: function(target) {
    console.log("Method isExtensible in file ruby_proxy.js");
    return false;
  },

  preventExtensions: function(target) {
    console.log("Method preventExtensions in file ruby_proxy.js");
    return true;
  },
  
  get: function(target, property) {
    var ruby_obj = this.ruby_obj;
    return function(...params) {
      var res;
      if(params.length > 0 && typeof params[params.length - 1] === "function") {
	temp_func = params.pop();
	var blk = `{ |*args| B.temp_func(*B.process_args2(args)) }`;
	params.push(blk);
      }
      switch (params.length) {
      case 0:
	res = ruby_obj.run(property);
	break;
      case 1:
	res = ruby_obj.run(property, params[0]);
	break;
      case 2:
	res = ruby_obj.run(property, params[0], params[1]);
	break;
      case 3:
	res = ruby_obj.run(property, params[0], params[1], params[2]);
	break;
      case 4:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3]);
	break;
      case 5:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4]);
	break;
      case 6:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5]);
	break;
      case 7:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6]);
	break;
      case 8:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6],
			   params[7]);
	break;
      case 9:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6],
			   params[7], params[8]);
	break;
      case 10:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6],
			   params[7], params[8], params[9]);
	break;
      case 11:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6],
			   params[7], params[8], params[9], params[10]);
	break;
      case 12:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6],
			   params[7], params[8], params[9], params[10],
			   params[11]);
	break;
      case 13:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6],
			   params[7], params[8], params[9], params[10],
			   params[11], params[12]);
	break;
      case 14:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6],
			   params[7], params[8], params[9], params[10],
			   params[11], params[12], params[13]);
	break;
      case 15:
	res = ruby_obj.run(property, params[0], params[1], params[2],
			   params[3], params[4], params[5], params[6],
			   params[7], params[8], params[9], params[10],
			   params[11], params[12], params[13], params[14]);
	break;
      }
      return res;
    }
  }
}
