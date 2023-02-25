require 'rubygems'
require 'bundler'

require "fileutils"
require 'openssl'
require 'digest'
require 'base64'
require 'securerandom'
require 'yaml'
require 'find'
require 'set'
require 'pathname'

Bundler.setup
Bundler.require

require 'active_support/all'

Config.load_and_set_settings "config/settings.yml", "config/settings.local.yml"

Config.setup do |config|
  config.const_name = 'Settings'
  config.use_env = true
  config.env_prefix = 'SETTINGS'
  config.env_separator = '__'
  config.env_converter = :downcase
end

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('app', Dir.pwd))
loader.setup
