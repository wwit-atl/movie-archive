require_relative '../../minitest_helper'

module WWIT
  module Archive
    class TestMovie < MiniTest::Test
      include TestSetup

      def setup
        super
        @datetime_sunday_1am = Time.parse('2014-Jun-22 01:00') # Sunday @ 1AM
        @movie = Movie.new(@test_file)
        @birth = Time.at(1403272792)
        refute_nil @movie
        assert_instance_of WWIT::Archive::Movie, @movie
      end

      def test_movie_valid?
        assert File.exist?(@test_file), "#{@test_file} does not exist"
        assert @movie.valid?, '@movie is not valid'

        # Create a bogus file and verify it doesn't actually exist
        file = "#{@test_directory}/bogus"
        refute File.exist?(file), "#{file} exists!?"

        # Create a new Movie object and verify it's not valid?
        assert_raises RuntimeError do
          Movie.new(file)
        end
      end

      def test_movie_directory
        assert_equal @test_directory, @movie.directory
      end

      def test_movie_fullpath
        assert_equal File.expand_path(@test_file), @movie.fullpath
      end

      def test_movie_filename
        assert_equal File.basename(@test_file), @movie.filename
      end

      def test_movie_basename
        assert_equal File.basename(@test_file, '.mp4'), @movie.basename
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
        assert_equal @birth, @movie.birth
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

        assert_equal File.expand_path(@test_directory) + '/' + filename, @movie.newfilename
        assert_equal "/tmp/#{filename}", @movie.newfilename('/tmp')
      end

      def test_movie_age
        assert_equal (Time.now - @birth).to_i, @movie.age.to_i
      end

      def test_movie_age_in_days
        assert_equal ((Time.now - @birth) / 86400).round(2), @movie.age_in_days
      end

      def test_movie_copy
        new_file = '/tmp/2014-Jun-20-Fri-2100.mp4'
        File.delete(new_file) if File.exists?(new_file)
        refute File.exists?(new_file), "#{new_file} already exists, control failed"
        @movie.process(true, new_file)
        assert File.exists?(new_file), "#{@test_file} wasn't copied to #{new_file}"
        File.delete(new_file) if File.exists?(new_file)
      end
    end
  end
end
