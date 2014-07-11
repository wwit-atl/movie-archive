#
# Movie File Container Class
#
#  Contains a series of MovieFile objects
#
require __dir__ + '/movie'

module WWIT
  module Archive
    class Movies
      require 'aws-sdk'

      def initialize( source = '.', opts = {} )
        @file_list = []

        if opts[:cloud] and Options.have_cloud_credentials?
          @bucket = AWS::S3.new(
              access_key_id:     AWS_ACCESS_KEY_ID,
              secret_access_key: AWS_SECRET_ACCESS_KEY,
              region:            AWS_REGION
          ).buckets[AWS_BUCKET]
        end

        [source].flatten.each do |dir|
          raise RuntimeError, "Invalid Directory: #{dir}" unless File.directory?(dir)
          Dir.glob(dir + '/*.{mp4,m4v}').sort.each { |file| @file_list << Movie.new( file ) }
        end

        # Clean up the data
        @file_list.flatten.uniq!
      end

      def cloud_valid?
        !@bucket.nil? and @bucket.exists?
      end

      # Returns an array of directories representing the files in the container
      def dirs
        @file_list.map { |movie| movie.directory }
      end

      def names
        @file_list.map { |movie| movie.filename }
      end

      def files
        @file_list.map { |movie| movie.fullpath }
      end

      # Iterator
      def each
        @file_list.each { |movie| yield movie }
      end

      # Returns the number of files in the collection
      def count
        @file_list.count
      end

      # Boolean; empty Array?
      def empty?
        @file_list.empty?
      end

      # Returns an array of filenames
      def to_a
        @file_list.map { |movie| movie.filename }
      end

      def <<(*files)
        files.flatten.map do |file|
          @file_list << Movie.new(file) unless self.files.include?(file)
        end
      end

    end # of Movies container class
  end
end
