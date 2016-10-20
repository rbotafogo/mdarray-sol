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
// data = {a: 1, b: 2, c: 3, d: {e: 4, f: 5, g: {h: 6, i:7}}}
// d2 = {x: 100, y: 200, c: 300}

var assert = chai.assert;

// Run a Ruby method that has special character not present in javascript, e.g., 'any?' and
// pass a function as a block
// CHECK WHY METHOD 'any?' receives param and delete_if has (key, value)! BUG?!! 
assert.equal(false, data["any?"](function(param) { return param[1] == 100;} ))
// assert.equal(true, data["any?"](function(param) { return param[1] == 3 ;} ))
/*
// Access to a hash
assert.equal(1, data.fetch("a"));
assert.equal(2, data.fetch("b"));

// Access to b hash
assert.equal(100, d2.fetch("x"));
assert.equal(200, d2.fetch("y"));
	     
// In javascript data["b"] is identical to data.b. This is a limitation of the 
// use of Ruby Hashes in javascript, as one should be carefull not to have a hash
// key identical to a hash method, as the key will hide the method
assert.equal(2, data["b"]);
assert.equal(2, data.b);

// add a value to the hash
data.j = "Hello from js";
assert.equal("Hello from js", data.j);

// Access a hash element inside another hash
assert.equal(4, data.d.e);
assert.equal(6, data.d.g.h);

// Calling methods has to follow javascript rules, i.e., use () even when the method
// has no arguments
// data.keys() is an array.
assert.equal("[:a, :b, :c, :d, :j]", data.keys().to_s());

data.delete_if (function(key, value) { return key == "a"; })

assert.equal("[:d, {:e=>4, :f=>5, :g=>{:h=>6, :i=>7}}]", data.assoc("d").to_s());

// There is one value that is equal to 3
assert.equal(true, data["any?"](function(param) { return param[1] == 3 ;} ))

// Delete any key that has 'a' as key value
data.delete_if (function(key, value) { return key == "a"; })

// Log the value of all hashes
data.each_pair (function(param) { console.log(param[1]); } )
*/
