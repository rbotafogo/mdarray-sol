require 'rake/testtask'

require_relative 'version'
require_relative 'config'

name = "#{$gem_name}-#{$version}.gem"

#==========================================================================================
# Compiling Java classes
#==========================================================================================

desc "Compile java to mdarray-sol.jar"
task :javac do
  files = Dir["#{Sol.src_dir}/**/*.java"]
  jars = Dir["#{Sol.vendor_dir}/*.jar"]
  classpath_directive = (jars.size > 0)? "-classpath #{jars.join(';')}" : ""

  sh "javac #{classpath_directive} -d #{Sol.classes_dir} #{files.join(' ')}"
end

#==========================================================================================
#
#==========================================================================================

desc 'Make jar file'
task :make_jar do

  Dir.chdir(Sol.classes_dir)
  classes = Dir['**/*.class']
  p classes
  sh "jar -cf #{Sol.target_dir}/mdarray_sol.jar #{classes.join(' ')}"

end

#==========================================================================================
#
#==========================================================================================

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

