#
# Movie File Container Class
#
#  Contains a series of MovieFile objects
#
require __dir__ + '/movie'

module WWIT
  class Movies

    def initialize( source_dirs = '.', opts = {})
      @file_list = []

      debug = !!opts[:debug]

      [source_dirs].flatten.each do |dir|
        raise RuntimeError, "Invalid Directory: #{dir}" unless File.directory?(dir)
        Dir.glob(dir + '/*.{mp4,m4v}').sort.each { |file| @file_list << Movie.new( file, debug ) }
      end

      # Clean up the data
      @file_list.flatten.uniq!
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
