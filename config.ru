require 'bundler'
Bundler.require

require 'opal/spec/server'

# method_missing can be turned off if required (on by default)
# Opal::Processor.method_missing_enabled = false

# Run in non-debug mode (faster, all files concatenated into 1 file)
run Opal::Spec::Server.new(false)

# Run in debug mode - all files loaded seperately, but slower
# run Opal::Spec::Server.new
