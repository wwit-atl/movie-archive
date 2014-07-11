require_relative '../minitest_helper'

class TestBinary < Minitest::Test
  def setup
    @command = 'env ruby -Ilib bin/movie-archive'
  end

  def test_version
    assert_equal WWIT::Archive::VSTRING, `#{@command} --version`.strip
  end

end
