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
    
  get: function(target, property) {
    var ruby_obj = this.ruby_obj;
    return function(...params) {
      if(params.length > 0 && typeof params[params.length - 1] === "function") {
	temp_func = params.pop();
	// create a block that will call the given function.  If the returned value
	// is a JSObject, then we need to return its jsvalue, since the result is
	// going back to a javascript script.  If it is not a JSObject, then it is
	// a primitive (Number, true, false, etc.) and just return it
	var blk = `{ |*args| ((ret = B.temp_func(*B.ruby2js(args))).is_a? JSObject)? ret.jsvalue : ret }`;
	params.push(blk);
      }
      switch (params.length) {
      case 0:
	return ruby_obj.run(property);
      case 1:
	return ruby_obj.run(property, params[0]);
      case 2:
	return ruby_obj.run(property, params[0], params[1]);
      case 3:
	return ruby_obj.run(property, params[0], params[1], params[2]);
      case 4:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3]);
      case 5:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4]);
      case 6:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5]);
      case 7:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6]);
      case 8:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7]);
      case 9:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8]);
      case 10:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9]);
      case 11:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10]);
      case 12:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10],
			    params[11]);
      case 13:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10],
			    params[11], params[12]);
      case 14:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10],
			    params[11], params[12], params[13]);
      case 15:
	return ruby_obj.run(property, params[0], params[1], params[2],
			    params[3], params[4], params[5], params[6],
			    params[7], params[8], params[9], params[10],
			    params[11], params[12], params[13], params[14]);
      }
    }
  },

  // TODO: This is propably not correct.  Check!!
  defineProperty: function(target, property, descriptor) {
    console.log("defineProperty");
    console.log(property);
    console.log(descriptor);
    return this.ruby_obj.run("[]=", property, descriptor.value);
  },

  isExtensible: function(target) {
    console.log("Method isExtensible in file ruby_proxy.js");
    return false;
  },

  preventExtensions: function(target) {
    console.log("Method preventExtensions in file ruby_proxy.js");
    return true;
  },

  apply: function(target, thisArg, argumentsList) {
    console.log("method apply in file ruby_proxy.js");
    console.log(target);
    console.log(thisArg);
    console.log(argumentsList);
    return true;
  },
  
  ownKeys: function(target) {
    console.log("method ownKeys in file ruby_proxy.js");
    return true;
  }
  
}


  /*
  get: function(target, property) {
    var ruby_obj = this.ruby_obj;
    return function(...params) {
      if(params.length > 0 && typeof params[params.length - 1] === "function") {
	// params[params.length - 1] = (String(params[params.length - 1]));
	temp_func = params.pop();
	var blk = `{ |*args| B.temp_func(*B.ruby2js(args)) }`;
	params.push(blk);
      }
      switch (params.length) {
      case 0:
	return RubyProxy(ruby_obj.run(property));
      case 1:
	return RubyProxy(ruby_obj.run(property, params[0]));
      case 2:
	return RubyProxy(ruby_obj.run(property, params[0], params[1]));
      case 3:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2]));
      case 4:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3]));
      case 5:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4]));
      case 6:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5]));
      case 7:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6]));
      case 8:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6],
				      params[7]));
      case 9:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6],
				      params[7], params[8]));
      case 10:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6],
				      params[7], params[8], params[9]));
      case 11:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6],
				      params[7], params[8], params[9], params[10]));
      case 12:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6],
				      params[7], params[8], params[9], params[10],
				      params[11]));
      case 13:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6],
				      params[7], params[8], params[9], params[10],
				      params[11], params[12]));
      case 14:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6],
				      params[7], params[8], params[9], params[10],
				      params[11], params[12], params[13]));
      case 15:
	return RubyProxy(ruby_obj.run(property, params[0], params[1], params[2],
				      params[3], params[4], params[5], params[6],
				      params[7], params[8], params[9], params[10],
				      params[11], params[12], params[13], params[14]));
      }
    }
  }*/
