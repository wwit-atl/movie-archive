#
# MovieFile Object Class
#
module WWIT
  class Movie

    attr_reader :filename, :directory
    attr_accessor :debug

    def initialize( dir, file, debug = false )
      @debug     = debug
      @directory = dir
      @filename  = file
    end

    KILOBYTE = 2 ** 10   # Base 2 (1024)
    MEGABYTE = 2 ** 20   # Base 2 (1024)
    GIGABYTE = 2 ** 30   # Base 2 (1024)
    TERABYTE = 10 ** 12  # Base 10 (1000)
    PETABYTE = 10 ** 15  # Base 10 (1000)

    # Returns the full pathname to the file
    def fullpath
      File.expand_path( @filename, @directory )
    end

    # Returns the filename minus the extension
    def basename
      File.basename( fullpath, ext )
    end

    # Returns the file extension
    def ext
      File.extname( fullpath )
    end

    # Returns the file size (in bytes)
    def size
      File.size( fullpath )
    end

    # Converts and returns the file size in a 0.00 float, based upon a given multiplier
    def size_to_f( multiplier = 1024 )
      "%.2f" % ( size.to_f / multiplier )
    end

    # Returns the birthdate modification time of the file
    def birth
      filename = Escape.shell_command(["#{fullpath}"])
      Time.at( %x(/usr/bin/stat -f'%B' #{filename}).to_i )
    end

    # Returns a string representing the appropriate abbreviated file size
    def size_to_s
      case
        when size == 0        then "Empty"
        when size >= PETABYTE then size_to_f( PETABYTE ) + "P"
        when size >= TERABYTE then size_to_f( TERABYTE ) + "T"
        when size >= GIGABYTE then size_to_f( GIGABYTE ) + "G"
        when size >= MEGABYTE then size_to_f( MEGABYTE ) + "M"
        when size >= KILOBYTE then size_to_f( KILOBYTE ) + "K"
        else size + "B"
      end
    end

    # Returns the calculated YYYY-MM-DD date string of the show
    def date( date = birth )
      # Check to be sure time is a valid Time object
      raise "Invalid Date" unless date.respond_to? :strftime

      if date.wday == 0 && date.hour <= 2
        self.date( date - 3600 ) # Call recursively - 1 hour
      else
        date.strftime( "%Y-%b-%d" )
      end
    end

    # Returns the calculated DDD-HHHH time string of the show
    def time( time = birth )
      # Check to be sure time is a valid Time object
      raise "Invalid Time" unless time.respond_to? :wday

      sday  = time.strftime( "%a" )
      stime = "2000"

      # Friday is a 9:00 PM show
      if time.wday == 5
        stime = "2100"
      end

      # Saturday after 10 PM file creation is 10:30 PM show
      if ( time.wday == 6 && time.hour >= 22 ) ||
          ( time.wday == 0 && time.hour <= 2  )
        sday  = "Sat"
        stime = "2230"
      end

      # Return the day-time string
      sday + '-' + stime
    end

    # Returns a string representing the calculated filename including the showdate and showtime
    def newfilename( destdir = @directory )
      raise ArgumentError, "Directory required" unless File.directory?( destdir )

      fname = self.date + '-' + self.time
      newfname = File.expand_path( fname, destdir ) + ext

      # If the file already exists, append a number
      index = 0
      while File.exist?( newfname )
        puts ">>> Comparing #{self.fullpath} with #{newfname}..." if @debug
        break if File.identical?( self.fullpath, newfname )
        newfname = File.expand_path( fname, destdir ) + "-" + ( index += 1 ).to_s + ext
        puts ">>> Not the same, generated #{newfname}" if @debug
      end

      newfname
    end

    # Moves the file to dest
    def move( dest = @directory, verbose = 0 )
      newfname = newfilename( dest )
      return if File.identical?( self.fullpath, newfname )
      puts "move #{self.fullpath} -> #{newfname} ( #{self.size_to_s} )" if verbose
      FileUtils.mv( self.fullpath, newfname )
    end

    # Copies the file to dest (preserving time and ownership information)
    def copy( dest = @directory, verbose = 0 )
      newfname = newfilename( dest )
      return if File.identical?( self.fullpath, newfname )
      puts "copy #{self.fullpath} -> #{newfname} ( #{self.size_to_s} )" if verbose
      FileUtils.cp( self.fullpath, newfname, :preserve => 1 )
    end

    #
    # Method aliases
    #
    alias :dir    :directory
    alias :name   :filename
    alias :to_s   :filename

  end # of MovieFile class
end
