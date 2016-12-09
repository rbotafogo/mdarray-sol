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

function RubyRich() {

  this.identity = function(value) {
    return value;
  },
  
  this.instanceOf = function(object, constructor) {
    while (object != null) {
      if (object == constructor.prototype)
	return true;
      if (typeof object == 'xml') {
        return constructor.prototype == XML.prototype;
      }
      object = object.__proto__;
    }
    return false;
  },
  
  this.new_object = function(...args) {
    var constructor = args.shift();
    return new constructor(...args);
  },

  this.symbol = function() {
    console.log(symbol_arg);
    return symbol_arg.toString();
  },

  // Makes a callback function from a given Ruby block.  The ruby block must be
  // stored in variable 'block' in javascript window.
  // TODO: Find what is going on here!!!  Why doesn´t the function work with an
  // argument!!!! Need to set blk = block... this is wrong!
  this.make_callback = function(blk) {
    blk = block;
    return function (...args) {
      blk.set_this(this);
      // this is a weird case... getting an undefined value on args[0]
      if (args[0] == undefined) {
	return blk.run("call");
      }
      else {
	return blk.run("call", ...args);
      }
    }
  }
  
};

var rr = new RubyRich();
