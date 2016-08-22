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

function RubyProxy(proxy) {
    
    this.proxy = proxy;
    
    this.arrayChangeHandler = {
	get: function(target, property){
	    if (isNaN(property)) {
		return function(...params) {
		    console.log(property + " params are: " + params);
		    if (typeof params[0] === "function") {
			return params[0](5);
		    } else {
			proxy.run(target, params);
		    }
		}
	    } else {
		console.log("my proxy is " + proxy.run("[]", parseInt(property)));
	    }
	},
	
	set: function(target, property, value, receiver) {
	    console.log("my proxy is ");
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
	
    }
    
    this.array = new Proxy([], this.arrayChangeHandler);
    return this.array;
    
}


