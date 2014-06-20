#
# Movie File Container Class
#
#  Contains a series of MovieFile objects
#
module WWIT
  class MovieFiles
    def initialize( source = ['.'], debug = false )
      @debug  = debug
      @files  = Array.new

      source.each do |dir|
        unless File.directory?(dir)
          raise "Invalid Directory: #{dir}"
          next
        end

        Dir.chdir( dir ) do
          @files << Dir.glob("*.{mp4,m4v}").sort.map { |file| Movie.new( dir, file, debug ) unless File.file?(file) }
        end
      end
    end

    # Returns an array of directories representing the files in the container
    def pwd
      @files.map { |file| file.dir if file.respond_to? :dir }
    end

    # Iterator
    def each
      @files.each { |file| yield file }
    end

    # Returns the number of files in the collection
    def count
      @files.count
    end

    # Boolean; empty Array?
    def empty?
      @files.empty?
    end

    # Returns an array of filenames
    def to_a
      @files.map { |file| file.filename if file.respond_to? :filename }
    end

  end # of MovieFiles container class
end
