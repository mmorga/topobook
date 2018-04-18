
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "topobook/version"

Gem::Specification.new do |spec|
  spec.name          = "topobook"
  spec.version       = Topobook::VERSION
  spec.authors       = ["Mark Morga"]
  spec.email         = ["markmorga@gmail.com"]

  spec.summary       = %q{Tool to build ebooks from a Topographic Map PDF}
  spec.description   = %q{Tool to build ebooks from a Topographic Map PDF}
  spec.homepage      = "https://github.com/mmorga/topobook"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.requirements << 'pdf2svg, v0.2.3 or newer'
  spec.requirements << 'pandoc, v2.1.3 or newer'
  spec.requirements << 'imagemagick, v7.0.7 or newer'
  spec.requirements << 'kindlegen, https://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211'
  spec.requirements << 'kindle-previewer, https://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765261'
  spec.requirements << 'node.js and npm'
  spec.requirements << 'svgo, npm i -g svgo'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop", "~> 0.55"
  spec.add_development_dependency "pry", "~> 0.11"

  spec.add_runtime_dependency "nokogiri", "~> 1.8"
end
