require 'rails/engine'
require 'sass/plugin/rack'
require 'govuk_frontend_toolkit'

Sass.load_paths << Gem.loaded_specs['govuk_frontend_toolkit'].full_gem_path + '/app/assets/stylesheets'
Sass::Plugin.add_template_location('bower_components/govuk_elements/public/sass')
