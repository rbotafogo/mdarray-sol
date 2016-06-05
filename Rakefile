require 'opal'
require 'opal-jquery'
require 'rake/testtask'

require_relative 'version'

name = "#{$gem_name}-#{$version}.gem"

#==========================================================================================
# For building with Opal
#==========================================================================================

desc "Build our app to conway.js"
task :build do
  # Opal.append_path "lib/app"
  Opal.append_path File.expand_path('lib/sol_engine', __FILE__)
  parser = Opal::Parser.new
  files = Dir['lib/sol_engine/**/*.rb']
  
  File.open("lib/mdarray-sol.js", "w+") do |stream|
    # stream << parser.parse(File.read("lib/sol_engine/mdarray-sol.rb"))
    files.each do |file|
      stream << Opal.compile(File.read(file))
    end
  end
end

#==========================================================================================
# Compiling Java classes (Not working!)
#==========================================================================================

rule '.class' => '.java' do |t|
  sh "javac #{t.source}"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/complete.rb']
  t.ruby_opts = ["--server", "-Xinvokedynamic.constants=true", "-J-Xmn512m", 
                 "-J-Xms1024m", "-J-Xmx1024m"]
  t.verbose = true
  t.warning = true
end

#==========================================================================================
# Gem management
#==========================================================================================

desc 'Makes a Gem'
task :make_gem do
  sh "jruby -S gem build #{$gem_name}.gemspec"
end

desc 'Install the gem in the standard location'
task :install_gem => [:make_gem] do
  sh "jruby -S gem install #{$gem_name}-#{$version}-java.gem"
end

desc 'Push gem to rubygem'
task :push_gem do
  sh "jruby -S gem push #{name}"
end

desc 'Make documentation'
task :make_doc do
  sh "yard doc lib/*.rb lib/**/*.rb"
end

#==========================================================================================
# GitHub management
#==========================================================================================

desc 'Push project to github'
task :push do
  sh "git push origin master"
end

