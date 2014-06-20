$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'wwit/archive'
require 'minitest/autorun'
require 'minitest/reporters'

MiniTest::Reporters.use!
# MiniTest::Reporters::DefaultReporter.new(color: true)
