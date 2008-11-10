Globalize
===

About
---
Radiant CMS localization using [Globalize][gl].

Docs to come. Stay tuned.

Installation
---

  git-submodule add git://github.com/ihoka/globalize.git vendor/plugins/globalize
  git-submodule add git://github.com/Aissac/radiant-globalize-extension.git vendor/extensions/globalize

environment.rb:
  GLOBALIZE_LANGUAGES = [:en]
  GLOBALIZE_BASE_LANGUAGE = 'ro'
  GLOBALIZE_SCOPED_MODELS = ['PageAttachment']
  
  ...
  include Globalize

[gl]: http://www.globalize-rails.org/