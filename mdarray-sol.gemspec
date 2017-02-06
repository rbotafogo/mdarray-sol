# -*- coding: utf-8 -*-
require 'rubygems/platform'

require_relative 'version'

Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "Front-end platform for desktop applications based on jxBrowser."
  gem.description = <<-EOF 
MDArray-sol, Sol for short, is a front-end platform for desktop application development 
based on the proprietary (yet free for open source) jxBrowser - https://www.teamdev.com/jxbrowser,
a Chromium-based browser.  In a sense Sol is similar to Opal in that it allows Ruby 
developers to code for the browser; however, differently from Opal, Sol does not compile 
its code to javascript, it implements a DSL that interfaces with javascript through 
jxBrowser java interface.  To the Ruby developer, no javascript is ever required.  Also, 
since there is no compilation there is no need to 'send' data from Ruby to Javascript, 
data in Ruby, for instance, in a Ruby array or hash, is made available directly to the browser. 
EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/mdarray-sol/wiki'
  gem.license = 'BSD-2-Clause'

  gem.add_dependency('jrubyfx','~>1.1')
  gem.add_runtime_dependency('mdarray', '~> 0.5')
  # gem.add_runtime_dependency('mdarray-jCSV', '~> 0.6' )
  # gem.add_runtime_dependency('insensitive_hash', '~> 0.3' )
  # gem.add_runtime_dependency('opal', '~> 0.9')
  # gem.add_runtime_dependency('opal-jquery', '~> 0.4')
  
  gem.add_development_dependency('shoulda', '~> 3.5')
  gem.add_development_dependency('simplecov', '~> 0.12')
  gem.add_development_dependency('yard', '~> 0.9')
  gem.add_development_dependency('kramdown', '~> 1.13')

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', 'version.rb', 'config.rb', 'init.rb',
                  '{lib,util,test,examples}/**/*.rb',
                  '{lib,node_modules}/**/*.js', 'util/cacert.pem', 'lib/**/*.html',
                  '{test,examples}/**/*.csv',
                  '{test,examples}/**/*.xlsx', 
                  '{bin,doc,spec,vendor,target}/**/*', 
                  'README*', 'LICENSE*'] # & `git ls-files -z`.split("\0")

  gem.test_files = Dir['test/*.rb']

  gem.platform='java'

end
