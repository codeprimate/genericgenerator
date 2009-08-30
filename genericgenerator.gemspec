# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{genericgenerator}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Patrick Morgan"]
  s.date = %q{2009-08-30}
  s.description = %q{GenericGenerator is an inheritable class that aids in quick generaration of data}
  s.email = %q{patrick.morgan@masterwebdesign.net}
  #s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = ["README.rdoc" , "History.txt" , "lib/genericgenerator.rb" ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/codeprimate/generator}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  a.rubyforge_project = %q{genericgenerator}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{GenericGenerator is an inheritable class that aids in quick generaration of data.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faker>, [])
      s.add_runtime_dependency(%q<ar-extensions>, [])
    else
      s.add_runtime_dependency(%q<faker>, [])
      s.add_runtime_dependency(%q<ar-extensions>, [])
  else
      s.add_runtime_dependency(%q<faker>, [])
      s.add_runtime_dependency(%q<ar-extensions>, [])
  end
end
