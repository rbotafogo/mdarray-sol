# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require_relative 'js'
require_relative 'bootstrap'

class Sol

  #==========================================================================================
  # This class executes in another thread than the GUI thread.  Communication between the
  # Dashboard and the GUI (WebView) is done through the Bridge class.
  #==========================================================================================
  
  class Dashboard

    attr_reader :name
    attr_reader :data
    attr_reader :dimension_labels
    attr_reader :date_columns     # columns that have date information
    
    # list of properties to be added to the dashboard.  These are Javascript sentences
    # that will be added at the right time to the embedded browser.  Dashboard properties
    # should be added before charts are added.
    attr_reader :properties

    attr_reader :charts           # All the charts to be added to the dashboard
    attr_reader :scene
    attr_reader :script           # automatically generated javascript script for this dashboard

    attr_reader :base_dimensions  # dimensions used by crossfilter

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def initialize(name, data, dimension_labels, date_columns = [])
      
      @name = name
      @data = data
      @dimension_labels = dimension_labels
      @date_columns = date_columns

      # Access the bridge to communicate with DCFX. Bridge is a singleton class
      @bridge = Bridge.instance

      # prepare a bootstrap scene specification for this dashboard
      @scene = Bootstrap.new
      
      @charts = Hash.new
      @properties = Hash.new
      @base_dimensions = Hash.new
      @runned  = false                      # dashboard has never executed

      # adds the dashboard data to the Browser
      add_data
      
    end
   
    #------------------------------------------------------------------------------------
    # Property that defines how to format date information.  Uses d3 time format.
    #------------------------------------------------------------------------------------
 
    def time_format(val = nil)
      return @properties["timeFormat"] if !val
      @properties["timeFormat"] = "var timeFormat = d3.time.format(\"#{val}\");"
      return self
    end

    #------------------------------------------------------------------------------------
    # @arg dim_name: name of the dimension
    # @arg dim: the actual crossfilter dimension (a column in the dataset)
    #------------------------------------------------------------------------------------

    def prepare_dimension(dim_name, dim)
      @base_dimensions[dim_name + "Dimension"] = dim
      return self
    end

    #------------------------------------------------------------------------------------
    # 
    #------------------------------------------------------------------------------------

    def dimension?(dim_name)
      !@base_dimension[Sol.camelcase(dim_name.to_s)].nil?
    end

    #------------------------------------------------------------------------------------
    # 
    #------------------------------------------------------------------------------------

    def title=(title)
      @scene.title=(title)
    end

    #------------------------------------------------------------------------------------
    # Create a new chart of the given type and name, usign x_column for the x_axis and 
    # y_column for the Y axis.  Set the default values for the chart.  Those values can
    # be changed by the user later.
    #------------------------------------------------------------------------------------
    
    def chart(type, x_column, y_column, name)

      prepare_dimension(x_column, x_column) if (@base_dimensions[x_column + "Dimension"] == nil)

      chart = Sol::Chart.build(type, x_column, y_column, name)

      # Set chart defaults. Should preferably be read from a config file 
      chart.elastic_y(true)
      chart.x_axis_label(x_column)
      chart.y_axis_label(y_column)
      chart.group(:reduce_sum)

      @charts[name] = chart
      chart

    end

    #------------------------------------------------------------------------------------
    # Converts the @base_dimensions into Javascript code to define the crossfilters´
    # dimensions.
    #------------------------------------------------------------------------------------

    def dimensions_spec

      facts = "#{@name.downcase}_facts"

      dim_spec = String.new
      @base_dimensions.each_pair do |key, value|
        dim_spec << "var #{key} = #{facts}.dimension(function(d) {return d[\"#{value}\"];});"
      end
      dim_spec

    end

    #------------------------------------------------------------------------------------
    # Prepare dashboard data and properties
    #------------------------------------------------------------------------------------

    def props

      dashboard = "#{@name.downcase}_dashboard"
      facts = "#{@name.downcase}_facts"
      data = "#{@name.downcase}_data"
      
      # convert the data to JSON format
      scrpt = <<-EOS

        var #{dashboard} = new DCDashboard();
        #{dashboard}.convert(#{@date_columns});
        // Make variable data accessible to all charts
        var #{data} = #{dashboard}.getData();
        //$('#help').append(JSON.stringify(#{data}));
        // add data to crossfilter and call it 'facts'.
        #{facts} = crossfilter(#{data});

      EOS

      @properties.each_pair do |key, value|
        scrpt << value
      end

      scrpt

    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def run

      # scrpt will have the javascript specification
      scrpt = String.new
      
      # add dashboard properties
      scrpt << props

      # add bootstrap container if it wasn't specified by the user.  
      @scene.create_grid((keys = @charts.keys).size, keys) if !@scene.specified?
      scrpt << @scene.bootstrap
      
      # add dimensions (the x dimension)
      scrpt << dimensions_spec
      
      # add charts
      @charts.each do |name, chart|
        # add the chart specification
        scrpt << chart.js_spec if !chart.nil?
      end
      
      # render all charts
      scrpt += "dc.renderAll();"

      # sends a message to the gui to execute the given script
      @bridge.send(:gui, :executeScript, scrpt)

    end
    
    #------------------------------------------------------------------------------------
    # When we re_run a script, there is no need to add the dashboard properties
    # again
    #------------------------------------------------------------------------------------
    
    def re_run

      # scrpt will have the javascript specification
      scrpt = String.new

      # add bootstrap container if it wasn't specified by the user
      @scene.create_grid((keys = @charts.keys).size, keys) if !@scene.specified?
      scrpt << @scene.bootstrap

      # add charts
      @charts.each do |name, chart|
        # add the chart specification
        scrpt << chart.js_spec if !chart.nil?
      end
      
      # render all charts
      scrpt += "dc.renderAll();"

      # sends a message to the gui to execute the given script
      @bridge.send(:gui, :executeScript, scrpt)
      
    end
    
    #------------------------------------------------------------------------------------
    # Cleans the scene and the charts, preparing for new visualization.
    #------------------------------------------------------------------------------------

    def clean
      @scene = Bootstrap.new
      @charts = Hash.new
    end

    #------------------------------------------------------------------------------------
    # Launches the UI and passes self so that it can add elements to it.
    #------------------------------------------------------------------------------------
    
    def plot

      # Remove all elements from the dashboard.  This could be changed in future releases
      # of the library.
      B.delete_all

      if (!@runned )
        run
        clean
        runned = true
      else
        re_run
      end

    end

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------

    def set_demo_script(scrpt)
      @demo_script = scrpt
    end

    private
    
    #------------------------------------------------------------------------------------
    # To add data to the WebView we should use Sol.add_data that uses the proper
    # communication channel.
    #------------------------------------------------------------------------------------

    def add_data
      Sol.add_data("native_array", @data.nc_array)
      Sol.add_data("labels", @dimension_labels.nc_array)
    end
    
  end
  
end

