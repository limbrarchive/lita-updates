Gem::Specification.new do |spec|
  spec.name          = "lita-standup"
  spec.version       = "0.1.0"
  spec.authors       = ["Pat Allan"]
  spec.email         = ["pat@freelancing-gods.com"]
  spec.summary       = "Standup Prompter for Slack"
  spec.homepage      = "https://github.com/limbrapp/lita-standup"
  spec.license       = "MIT"
  spec.metadata      = {"lita_plugin_type" => "handler"}

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"
  # spec.add_runtime_dependency "lita-slack"
  # spec.add_runtime_dependency "state_machine"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
