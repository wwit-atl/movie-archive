require_relative '../../minitest_helper'

module WWIT
  class TestMovie < MiniTest::Test
    def setup
      @datetime_sunday_1am = Time.parse('2014-Jun-22 01:00') # Sunday @ 1AM
      @dir = "#{__dir__}/../../samples"
      @file = 'test-friday-1k.mp4'
      @movie = Movie.new(@dir, @file)
      refute_nil @movie
      assert_instance_of WWIT::Movie, @movie
    end

    def test_movie_valid?
      assert File.exist?("#{@dir}/#{@file}"), "#{@dir}/#{@file} does not exist"
      assert @movie.valid?, '@movie is not valid'

      # Create a bogus file and verify it doesn't actually exist
      file = "#{@dir}/bogus"
      refute File.exist?(file), "#{file} exists!?"

      # Create a new Movie object and verify it's not valid?
      movie = Movie.new(@dir, file)
      refute movie.valid?, %q{@movie is valid but shouldn't be}
    end

    def test_movie_fullpath
      assert_equal File.expand_path("#{@dir}/#{@file}"), @movie.fullpath
    end

    def test_movie_basename
      assert_equal File.basename(@file, '.mp4'), @movie.basename
    end

    def test_movie_ext
      assert_equal '.mp4', @movie.ext
    end

    def test_movie_size
      assert_equal 1024, @movie.size
    end

    def test_movie_size_to_f
      assert_equal '1.00', @movie.size_to_f
    end

    def test_movie_size_to_s
      assert_equal '1.00K', @movie.size_to_s
    end

    def test_movie_birth
      assert_equal Time.at(1403272792), @movie.birth
    end

    def test_movie_date
      assert_raises RuntimeError do
        @movie.date(String.new)
      end

      assert_equal '2014-Jun-20', @movie.date
      assert_equal '2014-Jun-21', @movie.date(@datetime_sunday_1am)
      assert_equal '2014-Jun-21', @movie.date(@datetime_sunday_1am + 3600) # Add 1 hour
      assert_equal '2014-Jun-22', @movie.date(@datetime_sunday_1am + 3600*2) # Add 2 hours
    end

    def test_movie_time
      assert_raises RuntimeError do
        @movie.time(String.new)
      end

      assert_equal 'Fri-2100', @movie.time
      assert_equal 'Sat-2230', @movie.time(@datetime_sunday_1am)
      assert_equal 'Sat-2000', @movie.time(@datetime_sunday_1am - 3600*4) # Subtract 4 hours
      assert_equal 'Sun-2000', @movie.time(@datetime_sunday_1am + 3600*2) # Add 2 hours
    end

    def test_movie_newfilename
      filename = '2014-Jun-20-Fri-2100.mp4'

      assert_raises ArgumentError do
        @movie.newfilename(nil)
      end

      assert_equal File.expand_path(@dir) + '/' + filename, @movie.newfilename
      assert_equal "/tmp/#{filename}", @movie.newfilename('/tmp')
    end
  end
end
