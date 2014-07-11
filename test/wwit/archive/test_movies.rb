require_relative '../../minitest_helper'

module WWIT
  module Archive

    class TestMovies < MiniTest::Test
      include TestSetup

      def setup
        super
        @movies = Movies.new(@test_directory)
        refute_nil @movies
      end

      def test_movies_initialize
        movies = Movies.new
        refute_nil movies

        refute File.directory?('/bogus') # Make sure this dir really doesn't exist
        assert_raises RuntimeError do
          Movies.new('/bogus')
        end
      end

      def test_movies_dirs
        assert_equal [@test_directory], @movies.dirs
      end

      def test_movies_names
        assert_equal [@test_filename], @movies.names
      end

      def test_movies_files
        assert_equal [@test_file], @movies.files
      end

      def test_movies_add
        @movies << __FILE__
        assert_equal [@test_directory, File.dirname(__FILE__)], @movies.dirs
      end

      def test_movies_are_unique
        test_file = "#{__dir__}/test_movie.rb"

        @movies << [__FILE__, test_file, __FILE__]
        assert_equal [@test_file, __FILE__, test_file], @movies.files
      end

      def test_movies_empty?
        refute @movies.empty?, %q{movies is empty, but shouldn't be}
        assert Movies.new.empty?, %q{Movies is not empty but should be}
      end

      def test_movies_count
        assert_equal 0, Movies.new.count
        assert_equal 1, @movies.count
        @movies << __FILE__
        assert_equal 2, @movies.count
      end

      def test_movies_to_a
        assert_equal [@test_filename], @movies.to_a
      end

      def test_movies_iterator
        @movies.each do |movie|
          assert_instance_of WWIT::Archive::Movie, movie
          assert_equal @test_file, movie.fullpath
        end
      end

      def test_aws_credentials
        movies = Movies.new(@test_directory, cloud: true)
        assert Options.have_cloud_credentials?, 'Do not have cloud credentials'
        assert movies.cloud_valid?, 'Cloud credentials failed'
      end

    end
  end
end


