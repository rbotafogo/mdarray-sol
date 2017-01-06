Announcement
============

MDArray-sol version 0.1.0 has ben release.  MDArray-sol, Sol for short, is a front-end
platform for desktop application development based on the proprietary (yet free for
open source) jxBrowser - https://www.teamdev.com/jxbrowser, a Chromium-based browser.

In a sense, Sol is similar to Opal in that it allows Ruby developers to code for the
browser; however, differently from Opal, Sol does not compile its code to javascript,
it implements a DSL that interfaces with javascript through jxBrowser java interface,
more in line with what is provided by the javascript node-webkit, now called NW.js.
To the Ruby developer, no javascript is ever required.  Also, since there is no
compilation there is no need to 'send' data from Ruby to Javascript.  Data in Ruby,
for instance, in a Ruby array or hash, is made available directly to the browser. 

This is an initial version that focus on the integration of Ruby with the D3.js library.
In order to test this integration we have implemented many of the examples of the
excellent and highly recommended book by Scott Murray, "Interactive Data Visualization
for the Web".  As can be seen in the examples directory and on the MDArray-sol wiki at
https://github.com/rbotafogo/mdarray-sol/wiki, quite complex behaviour is already
possible in this version.

This version was tested on Cygwin, Windows and Linux64.  It has not yet been tested on
Linux32 nor Mac.  

Bellow is an example of the integration of D3.js with Ruby that plots the US States map:
    

    require 'json'
    require 'mdarray-sol'

    class Map

      attr_reader :path
      attr_reader :svg
      attr_reader :us_states
    
      #------------------------------------------------------------------------------------
      # @param width [Number]: width of the chart
      # @param height [Number]: height of the chart
      #------------------------------------------------------------------------------------

      def initialize(width, height)
      
        @width = width
        @height = height

        # Create svg for the map
        @svg = $d3.select("body")
                  .append("svg")
                  .attr("width", @width)
                  .attr("height", @height)
    
      end
  
      #------------------------------------------------------------------------------------
      # Parses a file in GeoJson format and saves it as @us_states
      # @param filename [String] the name of the file to parse
      #------------------------------------------------------------------------------------

      def json(filename)
        
        dir = File.expand_path(File.dirname(__FILE__))
        file_name = dir + "/#{filename}"
        file = File.read(file_name)
    
        # parse the json file
        @us_states = JSON.parse(file)

      end
  
      #------------------------------------------------------------------------------------
      #
      #------------------------------------------------------------------------------------

      def plot(projection)
    
        proj = projection
                 .translate([@width/2, @height/2])
                 .scale(500)
		 
        @path = $d3.geo.path[].projection(proj);    
        
        @svg.selectAll("path")
            .data(@us_states["features"])
            .enter[]
            .append("path")
            .attr("d", @path)
            .style("fill", "steelblue")
        
      end
      
    end

    map = Map.new(500, 500)
    map.json("us-states.json")
    map.plot($d3.geo.albersUsa[])


![US States Map](https://github.com/rbotafogo/mdarray-sol/blob/master/images/Map.JPG)


LICENSE
=======

MDArray-sol is distributed with the BSD 2-clause license; however, MDArray-sol uses JxBrowser
http://www.teamdev.com/jxbrowser, which is a proprietary software. The use of JxBrowser
is governed by JxBrowser Product Licence Agreement
http://www.teamdev.com/jxbrowser-licence-agreement. If you would like to use JxBrowser
in your development, please contact TeamDev.


MDArray-sol main properties are:
============================

  + Integration of Ruby and Javascript transparantly to the Ruby developer
  + Data sharing between Ruby and Javascript
  + Embedded browser

MDArray-sol installation and download:
==================================

  + Install Jruby
  + jruby –S gem install mdarray-sol

MDArray-sol Homepages:
==================

  + http://rubygems.org/gems/mdarray-sol
  + https://github.com/rbotafogo/mdarray-sol/wiki

Contributors:
=============
Contributors are welcome.


MDArray-sol History:
================

  + 2017/01/06: Initial release
