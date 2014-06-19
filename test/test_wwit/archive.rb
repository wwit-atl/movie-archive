require_relative '../minitest_helper'

module WWIT
  # class TestArchive < MiniTest::Unit::TestCase
  class TestArchive < MiniTest::Test
    def test_that_it_has_a_version_number
      refute_nil ::WWIT::Archive::VERSION
    end

    def test_it_does_something_useful
      assert false
    end
  end
end
