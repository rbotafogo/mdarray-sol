# -*- coding: utf-8 -*-
require 'rubygems/platform'

require_relative 'version'

Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "Visual library for MDArray based on DC.js, which depends on D3.js and 
crossfilter.js"
  gem.description = <<-EOF 
MDArray-sol is a visual (graphics) library for MDArray based on DC.js. According to dc.js website
(https://dc-js.github.io/dc.js/) dc.js is a javascript charting library with native crossfilter 
support and allowing highly efficient exploration on large multi-dimensional dataset (inspired by 
crossfilter's demo). It leverages d3 engine to render charts in css friendly svg format. Charts 
rendered using dc.js are naturally data driven and reactive therefore providing instant feedback 
on user's interaction. The main objective of this project is to provide an easy yet powerful 
javascript library which can be utilized to perform data visualization and analysis in browser as 
well as on mobile device.

MDArray-sol however does not require the use of a browser.  It uses an embbeded browser from 
JavaFX, by using JRubyFX libraries, making it even easier to create graphics and visualizatioons
without requiring starting a server and connecting to the server with the browser.
EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/mdarray-sol/wiki'
  gem.license = 'BSD 2-clause'

  gem.add_dependency('jrubyfx','~>1.1')
  gem.add_runtime_dependency('mdarray', '~> 0.5')
  gem.add_runtime_dependency('mdarray-jCSV', '~> 0.6' )
  gem.add_runtime_dependency('opal', '~> 0.9')
  gem.add_runtime_dependency('opal-jquery', '~> 0.4')
  
  gem.add_development_dependency('shoulda')
  gem.add_development_dependency('simplecov', [">= 0.7.1"])
  gem.add_development_dependency('yard', [">= 0.8.5.2"])
  gem.add_development_dependency('kramdown', [">= 1.0.1"])

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', 'version.rb', 'config.rb', '{lib,test}/**/*.rb', 'test/**/*.csv',
                  'test/**/*.xlsx',
                  '{bin,doc,spec,vendor,target}/**/*', 
                  'README*', 'LICENSE*'] # & `git ls-files -z`.split("\0")

  gem.test_files = Dir['test/*.rb']

  gem.platform='java'

end
