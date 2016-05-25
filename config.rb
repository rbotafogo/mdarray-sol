require 'rbconfig'
require 'java'

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

# the platform
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

#---------------------------------------------------------------------------------------
# Set the project directories
#---------------------------------------------------------------------------------------

class Sol

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
  
  class << self
    attr_reader :project_dir
    attr_reader :doc_dir
    attr_reader :lib_dir
    attr_reader :src_dir
    attr_reader :target_dir
    attr_reader :test_dir
    attr_reader :vendor_dir
  end

  @build_dir = Sol.src_dir + "/build"

  class << self
    attr_reader :build_dir
  end

  @classes_dir = Sol.build_dir + "/classes"

  class << self
    attr_reader :classes_dir
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
