$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'wwit/archive'
require 'minitest/autorun'
require 'minitest/reporters'

MiniTest::Reporters.use!
# MiniTest::Reporters::DefaultReporter.new(color: true)

module TestSetup
  def setup
    @test_directory = File.expand_path("#{__dir__}/samples")
    @test_filename = 'test-friday-1k.mp4'
    @test_file = "#{@test_directory}/#{@test_filename}"

    assert File.exist?(@test_file), "#{@test_file} does not exist"
  end
end