# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scalarm/database/version'

Gem::Specification.new do |spec|
  spec.name          = "scalarm-database"
  spec.version       = Scalarm::Database::VERSION
  spec.authors       = ["Jakub Liput"]
  spec.email         = ["jakub.liput@gmail.com"]
  spec.summary       = %q{An ODM (Object-Document Mapping), utils and models to use Scalarm database (MongoDB)}
  spec.description   = %q{Contains MongoActiveRecord, which is a base to create MongoDB models (similar to ActiveRecords)
and Scalarm model classes}
  spec.homepage      = "https://github.com/Scalarm/scalarm-database"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'mocha'

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'bson'
  spec.add_runtime_dependency 'bson_ext'
  spec.add_runtime_dependency 'mongo'
  spec.add_runtime_dependency 'encryptor'
end
