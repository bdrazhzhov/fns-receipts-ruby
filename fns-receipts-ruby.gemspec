# frozen_string_literal: true

require_relative 'lib/fns/version'
require_relative 'lib/fns'

Gem::Specification.new do |spec|
  spec.name = 'fns-receipts-ruby'
  spec.version = Fns::VERSION
  spec.authors = ['Boris Drazhzhov']
  spec.email = ['bdrazhzhov@gmail.com']

  spec.summary = 'Ruby-обертка над API, используемом мобильным приложением проверки чеков ФНС'
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = 'https://github.com/bdrazhzhov/fns-receipts-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/bdrazhzhov/fns-receipts-ruby',
    'rubygems_mfa_required' => 'true'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'http', '~> 5.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
