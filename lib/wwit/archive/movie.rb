require 'fileutils'

#
# MovieFile Object Class
#
module WWIT
  module Archive
    class Movie < File

      attr_reader :file, :output

      def initialize( file )
        raise RuntimeError, "ENOEXIST: #{file} is not valid" unless File.exist?(file)
        @file = file
        @output = []
        @debug_output = []
      end

      # Boolean, is file valid?
      def valid?
        File.exist?(fullpath)
      end

      def directory
        File.dirname(fullpath)
      end

      # Returns the full pathname to the file
      def fullpath
        File.expand_path( @file )
      end

      # Returns the filename minus the extension
      def basename
        File.basename( fullpath, ext )
      end

      # Returns the filename minus the directory
      def filename
        File.basename( fullpath )
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
        '%.2f' % ( size.to_f / multiplier )
      end

      # Returns the birthdate modification time of the file
      def birth
        Time.at %x(`which stat` -f'%B' #{fullpath}).to_i
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

      # Returns the calculated YYYY-MM-DD date string of the show.
      # Dates up to 2AM on Sunday are considered the previous Saturday
      def date( datetime = birth )
        # Check to be sure time is a valid Time object
        raise RuntimeError, 'Invalid Date' unless datetime.instance_of? Time

        if datetime.wday == 0 && datetime.hour <= 2
          self.date( datetime - 3600 ) # Call recursively - 1 hour
        else
          datetime.strftime( '%Y-%b-%d' )
        end
      end

      # Returns the calculated DDD-HHHH time string of the show
      def time( time = birth )
        # Check to be sure time is a valid Time object
        raise RuntimeError, 'Invalid Time' unless time.instance_of? Time

        show_day  = time.strftime( '%a' )
        show_time = '2000' # Defaults to 8PM

        # Friday is a 9:00 PM show
        show_time = '2100' if time.wday == 5

        # Saturday after 10 PM file creation is 10:30 PM show
        if ( time.wday == 6 && time.hour >= 22 ) || ( time.wday == 0 && time.hour <= 2  )
          show_day  = 'Sat'
          show_time = '2230'
        end

        # Return the day-time string
        show_day + '-' + show_time
      end

      # Returns a string representing the calculated filename including the showdate and showtime
      def newfilename( destdir = directory )
        raise ArgumentError, 'Directory required' unless File.directory?( destdir.to_s )

        fname = date + '-' + time
        newfname = File.expand_path( fname, destdir ) + ext

        # If the file already exists, append a number
        index = 0
        while File.exist?( newfname )
          @debug_output << ">>> Comparing #{fullpath} with #{newfname}..."
          break if File.identical?( fullpath, newfname )
          newfname = File.expand_path( fname, destdir ) + "-" + ( index += 1 ).to_s + ext
          @debug_output << ">>> Not the same, generated #{newfname}"
        end

        newfname
      end

      def process( dest = directory, copy = false )
        newfname = newfilename( dest )

        if File.identical?( fullpath, newfname )
          return "#{fullpath} already exists in #{dest}"
        end

        if copy
          FileUtils.cp( fullpath, newfname, :preserve => 1 )
        else
          FileUtils.mv( fullpath, newfname )
        end
      end

      alias_method :dir,      :directory
      alias_method :name,     :filename
      alias_method :to_s,     :filename

    end # of MovieFile class
  end
end
