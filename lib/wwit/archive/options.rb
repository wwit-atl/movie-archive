require 'ostruct'
require 'optparse'
require 'wwit/archive/globals'

module WWIT
  module Archive
    class Options

      def self.default_options
        {
            source:  ['.'],
            dest:    nil,
            days:    30,
            copy:    false,
            dryrun:  false,
            verbose: true,
            debug:   false
        }
      end

      def self.parse( argv_opts = [] )

        options = OpenStruct.new

        # Set defaults
        Options.default_options.each do |key, value|
          options[key] = value
        end

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: #{IDENT} [options]"
          opts.separator ''
          opts.separator 'Common Options:'

          opts.on('-s', '--source DIR', 'Search for movie files in DIR -- may be supplied more than once') do |dir|
            dir = File.expand_path(dir.strip)
            if Dir.exists?(dir)
              options.source.shift if options.source[0] == '.' and options.source.count == 1 # Remove default value
              options.source << dir
            else
              puts "Whoops: '#{dir}' is not a directory."
              exit
            end
          end

          opts.on('-d', '--dest DIR', 'This is where the resulting files will be placed.') do |dir|
            dir = File.expand_path(dir.strip)
            if Dir.exists?(dir)
              options.dest = dir
            else
              puts "Whoops: '#{dir}' is not a directory" + ( dir =~ /^\d+$/ ? "... maybe you meant '-D #{dir}'?" : '' )
              exit
            end
          end

          opts.on('-D', '--days #',
                  "The number of days to keep in the current directory (default = #{Options.default_options[:days]}).") do |days|
            days = 0 if days.to_i < 0
            options.days = days.to_i
          end

          opts.separator ''
          opts.separator 'Additional Options:'

          opts.on('-c', '--[no-]copy', 'Copy the files rather than move them') do |c|
            options.copy = c
          end

          opts.on('-v', '--[no-]verbose', 'Run verbosely (default)') do |v|
            options.verbose = v
          end

          opts.on('-q', '--silent', 'Runs quietly') do
            options.verbose = false
          end

          opts.on('--dryrun', %q{Doesn't actually make any changes to the filesystem}) do |d|
            options.dryrun = d
          end

          opts.on('--debug', 'Run with debugging options') do |debug|
            options.debug = debug
          end

          opts.on_tail('-h', '--help', 'Show this message') do
            puts opts
            exit
          end

          opts.on_tail('-V', '--version', 'Show version') do
            puts "#{IDENT} v.#{VERSION} - #{AUTHOR}"
            exit
          end

        end

        opt_parser.parse!(argv_opts)
        options
      end

    end
  end
end
