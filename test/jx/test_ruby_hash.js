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

/* This file tests the integration of javascript with Ruby Hashes.  Both javascript and 
 * Ruby have the same hash as backing store.  Although there is no hash in javascript
 * this is emmulated in mdarray-sol library.
 */

// This is the given hash
// a = {a: 1, b: 2, c: 3, d: {e: 4, f: 5}}
// b = {x: 100, y: 200, c: 300}


var assert = chai.assert;

// Access to a hash
assert.equal(1, data.fetch("a"));
assert.equal(2, data.fetch("b"));

// Access to b hash
assert.equal(100, d2.fetch("x"));
assert.equal(200, d2.fetch("y"));
	     
// In javascript data["b"] is identical to data.b. This is a limitation of the 
// use of Ruby Hashes in javascript, as one should be carefull not to have a hash
// key identical to a hash method, as the key will hide the method
//assert.equal(2, data["b"]);
//assert.equal(2, data.b);

// add a value to the hash
data.j = "Hello from js";
assert.equal("Hello from js", data.j);

assert.equal(4, data.d.e);

// data.keys() is an array.
assert.equal("[:a, :b, :c, :d, :j]", data.keys().to_s());

// console.log(data["any?"]())

// console.log(data["any?"](function(param) { return param[1] == 100 ;} ))

console.log(data.keys().to_s());

data.delete_if (function(key, value) { return key == "a"; })


//console.log(data.b)
//console.log(data.c)

// console.log(data["any?"]("function(key, value) {true}"))
// console.log(data.assoc("a").to_s());
