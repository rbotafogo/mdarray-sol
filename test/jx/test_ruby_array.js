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

var assert = chai.assert;

// This is the Ruby Array
// a = [1, 2, 3, 4] proxying 'data'

console.log("Starting Ruby Array proxy tests")

assert.equal(1, data[0]);
assert.equal(2, data[1]);
assert.equal(3, data[2]);
assert.equal(4, data[3]);

// calling method map (this is the Ruby map method) which has the same
// semantic as javascript map.  But should be careful not to confuse 
// things
data.map(function(d) { console.log(d); } )

// Note that we can use negative indices on this array
assert.equal(3, data[-2]);

// Need to use javascript syntax and put () after a function
assert.equal(4, data.length());
assert.equal(3, (data.last(2)[0]));

assert.equal("[1, 2, 3, 4]", data.to_s());

console.log("Ending Ruby Array proxy tests")