#!/usr/bin/env ruby

require 'rubygems'
require 'getoptions'
require 'fileutils'
require 'escape'

##
## Constants / Globals
##

# Defaults for options
defaults = {
  'source' => [ "." ],
  'dest'   => ".",
  'days'   => 30,
}

Version = "1.3.0"
Ident   = "MovieArchive"
Author  = "Donovan C. Young"
Vstring = "#{Ident} v.#{Version} - #{Author}"

##
## Functions
##

# Display version string and exit
def version
  puts Vstring
  exit( -1 )
end

# Display help/usage information and exit
def usage
  print <<-EoT

#{Vstring}

Usage: #{$0} [OPTIONS]

  [OPTIONS]

    --help    | -h                     This help file
    --version | -V                     Show the version infomation and exit
    --verbose | -v                     Increase program output (may be repeated)

    --source  | -s <DIR [DIR [...]]>   Searches for files in DIR (multiple directories may be given)
    --dest    | -d <DIR>               This is where the resulting files will be placed.
    --days    | -D <#>                 The number of days to keep in the current directory.

    --copy    | -c                     Copy the file (rather than move it)
    --dryrun                           Doesn't actually make changes to the filesystem

  EoT
  exit( -1 )
end

##
## Classes
##

#
# MovieFile Object Class
#
class MovieFile

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

#
# Movie File Container Class
#
#  Contains a series of MovieFile objects
#
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

##
## MAIN
##

# Don't do anything if we're only including this file's classes
if __FILE__ == $0

  opt = GetOptions.new(
    %w(
      help
      verbose|v+
      version|V
      dryrun
      copy
      source|s=@s
      dest|d=s
      days|D=i
    )
  )

  usage if opt.help
  version if opt.version

  # Set defaults for missing options
  source = opt.source ? opt.source : defaults['source']
  dest   = opt.dest
  days   = opt.days ? opt.days : defaults['days']
  days   = 0 if days < 0

  raise "Destination directory doesn't exist: #{dest}" if dest and not File.directory?( dest )

  if opt.verbose >= 3
    puts "Source is " + source.join(', ')
    puts "Dest   is " + dest if dest
    puts "Working on files older than #{days} day#{days > 1 ? 's' : ''}" if days > 0
  end

  # Create our movies object -- which, in turn, contains each movie file in the given source dir(s)
  movies = MovieFiles.new( source, opt.verbose >= 5 )

  if movies.empty?
    puts "No Files Found." if opt.verbose
    exit
  end

  action = opt.copy ? "copying" : "moving"

  if opt.verbose
    print "#{action} #{movies.count} files... "
    $stdout.flush
    puts if opt.verbose > 1
  end

  # Today's datetime
  today = Time.new

  # Process each movie file
  for movie in movies

    # Make sure it's older than the days to keep
    days_old = ( (today - movie.birth) / 86400 )
    if days_old <= days
      puts "Skipped #{movie}:  Too New (#{days_old.to_i} days old)" if opt.verbose >= 3
      next
    end

    dest = movie.dir unless dest
    newfile = movie.newfilename( dest )

    puts "#{action} #{movie.fullpath} -> #{newfile} ( #{movie.size_to_s} )" if opt.verbose >= 4

    # Skip further processing if --dryrun was given
    next if opt.dryrun

    if opt.copy
      movie.copy( dest, opt.verbose >= 3 )
      print "+ " if opt.verbose == 1
    else
      movie.move( dest, opt.verbose >= 3 )
      print "> " if opt.verbose == 1
    end
    $stdout.flush # Flush anything in the STDOUT buffer

  end

  puts "Complete" if opt.verbose
  exit( 0 )

end # of program
