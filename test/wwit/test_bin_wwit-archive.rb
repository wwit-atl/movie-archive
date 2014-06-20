require_relative '../minitest_helper'

module WWIT
  class TestArchive < MiniTest::Test

    def test_that_it_has_a_version_number
      refute_nil WWIT::Archive::VERSION
    end

  end
end
