#
# Movie File Container Class
#
#  Contains a series of MovieFile objects
#
module WWIT
  class MovieFiles
    def initialize( source = ["."], debug = false )
      @debug  = debug
      @files  = Array.new

      for dir in source
        unless File.directory?(dir)
          raise "Invalid Directory: #{dir}"
          next
        end

        Dir.chdir( dir ) {
          for file in Dir.glob("*.{mp4,m4v}").sort
            next unless File.file?( file )
            @files.push( MovieFile.new( dir, file, debug ) )
          end
        }
      end
    end

    # Returns an array of directories representing the files in the container
    def pwd
      dirs = Hash.new
      for file in @files.each
        dirs[ file.dir ] = "" if file.respond_to? :dir
      end
      dirs.keys
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
      filelist = Array.new
      for file in @files.each
        filelist.push( file.filename ) if file.respond_to? :filename
      end
      filelist
    end
  end # of MovieFiles container class
end
