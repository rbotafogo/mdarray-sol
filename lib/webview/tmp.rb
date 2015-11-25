graph = new DCGraph();
graph.convert(["Date"]);
var data = graph.getData();
//$('#help').append(JSON.stringify(data));
var timeFormat = d3.time.format(\"%d/%m/%Y\");
// Add data to crossfilter
facts = crossfilter(data);
d3.select(\"body\")
  .append(\"div\")
  .attr(\"id\", \"DateOpenChart\");
var DateOpen = dc.lineChart(#DateOpenChart);
DateOpen
  .width(700)
  .height(200)
  .margins("{top: 10, right:10, bottom: 50, left: 100}")
  .elasticY(true)
  .x("Date")
  .xAxisLabel("Date")
  .y("Open")
  .yAxisLabel("Open")
  .dimension\"timeDimension");

dc.renderAll();"
.





=begin
	        # This exclamation mark means "yes, normally you would add this to the parent,
	        # however don't add it, just create a javaFX MenuBar object"
          menu_bar = menu_bar! do
            menu("File") do
              menu_item("Open") do
                set_on_action do
                  file_chooser do
                    file = show_open_dialog(stage)
                    # pane.center browser # multi_touch_image_view(file.to_uri.to_s)
                  end
                end
              end
              menu_item("Quit") do
                set_on_action do
                  # res = @web_engine.executeScript("$('#demo').html('jquery text')")
                  # elmt = @document.getElementById("demo")
                  # elmt.childNodes.item(0).nodeValue = "New text"
                end
              end
            end
          end
          top menu_bar
=end
  
=begin
    pane = build(BorderPane)
    menu_bar = build(MenuBar)
    menu_file = build(Menu, "File")
    open = build(MenuItem, "Open")
    open.set_on_action do
      file_chooser do
        file = show_open_dialog(stage)
        pane.center browser # multi_touch_image_view(file.to_uri.to_s)
      end
    end
    quit = build(MenuItem, "Quit")
    menu_file.get_items.add_all(open, quit)
    menu_edit = build(Menu, "Edit")
    menu_view = build(Menu, "View")
    menu_bar.get_menus.add_all(menu_file, menu_edit, menu_view)
=end
