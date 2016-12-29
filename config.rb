require 'rbconfig'
require 'java'
require 'net/http'

#
# In principle should not be in this file.  The right way of doing this is by executing
# bundler exec, but I don't know how to do this from inside emacs.  So, should comment
# the next line before publishing the GEM.  If not commented, this should be harmless
# anyway.
#

begin
  require 'bundler/setup'
rescue LoadError
end

#---------------------------------------------------------------------------------------
# Set the project directories
#---------------------------------------------------------------------------------------

class Sol

  #-------------------------------------------------------------------------------------
  # Instance variables with information about directories and files used
  #-------------------------------------------------------------------------------------
  
  @home_dir = File.expand_path File.dirname(__FILE__)

  class << self
    attr_reader :home_dir
  end

  @project_dir = Sol.home_dir + "/.."
  @doc_dir = Sol.home_dir + "/doc"
  @lib_dir = Sol.home_dir + "/lib"
  @src_dir = Sol.home_dir + "/src"
  @target_dir = Sol.home_dir + "/target"
  @test_dir = Sol.home_dir + "/test"
  @vendor_dir = Sol.home_dir + "/vendor"
  @js_dir = Sol.home_dir + "/node_modules"

  # directory where jxbrowser jar files are stored on the web
  @jxbrowser_dir = "https://gist.github.com/rbotafogo/8e5425494c08b8db1d7228a1f4a726fe/raw"
  @jxwin = "fd2d0248522759dd5325b411825df7c2015119e4/jxbrowser-win-6.8.jar"
  
  class << self
    attr_reader :project_dir
    attr_reader :doc_dir
    attr_reader :lib_dir
    attr_reader :src_dir
    attr_reader :target_dir
    attr_reader :test_dir
    attr_reader :vendor_dir
    attr_reader :js_dir
    attr_reader :jxbrowser_dir
    attr_reader :jxwin
  end

  @build_dir = Sol.src_dir + "/build"

  class << self
    attr_reader :build_dir
  end

  @classes_dir = Sol.build_dir + "/classes"

  class << self
    attr_reader :classes_dir
  end

  #-------------------------------------------------------------------------------------
  # Environment information
  #-------------------------------------------------------------------------------------

  @platform = 
    case RUBY_PLATFORM
    when /mswin/ then 'windows'
    when /mingw/ then 'windows'
    when /bccwin/ then 'windows'
    when /cygwin/ then 'windows-cygwin'
    when /java/
      require 'java' #:nodoc:
      if java.lang.System.getProperty("os.name") =~ /[Ww]indows/
        'windows-java'
      else
        'default-java'
      end
    else
      'default'
    end
  
  @host_os = RbConfig::CONFIG['host_os']

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------

  def self.windows?
    !(@host_os =~ /mswin|mingw/).nil?
  end  

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------

  def self.linux32?
    !(@host_os =~ /linux32/).nil?
  end

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------

  def self.linux64?
    !(@host_os =~ /linux64/).nil?
  end

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------

  def self.mac?
    !(@host_os =~ /mac|darwin/).nil?
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.http_download_uri(uri, filename)
    puts "Starting HTTP download for: " + uri.to_s
    http_object = Net::HTTP.new(uri.host, uri.port)
    http_object.use_ssl = true if uri.scheme == 'https'
    begin
      http_object.start do |http|
        request = Net::HTTP::Get.new uri.request_uri
        http.read_timeout = 500
        http.request request do |response|
          open filename, 'wb' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
    rescue Exception => e
      puts "=> Exception: '#{e}'. Skipping download."
      return
    end
    puts "Stored download as " + filename + "."
  end
  
  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------

  def self.jxBrowser?
    
    case @host_os
    when /mswin|mingw/
      if (!FileTest.exists?("#@vendor_dir/jxbrowser-win-6.8.jar"))
        puts "Missing jxBrowser for Windows Platform... "
        spec = "#@jxbrowser_dir/#@jxwin"
        puts "Downloading file: #{spec}"
        uri = URI(spec)
        http_download_uri(uri, Sol::vendor_dir + "/#@jxwin")
      end
    when /linux32/

    # https://gist.github.com/rbotafogo/8e5425494c08b8db1d7228a1f4a726fe/raw/902699d3017e6cda80370f9bcb7aba6a331070a8/jxbrowser-linux32-6.8.jar
      
    when /linux64/

    when /mac|darwin/

    end
    
  end
  
end

#----------------------------------------------------------------------------------------
# If we need to test for coverage
#----------------------------------------------------------------------------------------

if $COVERAGE == 'true'
  
  require 'simplecov'
  
  SimpleCov.start do
    @filters = []
    add_group "Sol"
  end
  
end

##########################################################################################
# Load necessary jar files
##########################################################################################

Dir["#{Sol.vendor_dir}/*.jar"].each do |jar|
  require jar
end

Dir["#{Sol.target_dir}/*.jar"].each do |jar|
  require jar
end

Sol::jxBrowser?
