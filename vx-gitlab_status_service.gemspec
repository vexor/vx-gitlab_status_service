# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vx/gitlab_status_service/version'

Gem::Specification.new do |spec|
  spec.name          = "vx-gitlab_status_service"
  spec.version       = Vx::GitlabStatusService::VERSION
  spec.authors       = ["Semenyuk Dmitriy"]
  spec.email         = ["mail@semenyukdmitriy.com"]
  spec.summary       = %q{Gitlab v6 build status service.}
  spec.description   = %q{Integrates Gitlab with Vexor CI (build status & build link on merge request pages)}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "shoulda-matchers", "~> 2.1.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "httparty"
  spec.add_dependency "activerecord"
  spec.add_dependency "protected_attributes"
end
