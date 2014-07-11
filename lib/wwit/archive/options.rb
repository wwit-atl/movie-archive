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
            cloud:   have_cloud_credentials?,
            dryrun:  false,
            verbose: true,
            debug:   false
        }
      end

      def self.have_cloud_credentials?
        File.exists?(File.expand_path('~/.aws/credentials')) or
            !( ENV['AWS_ACCESS_KEY_ID'].nil? or ENV['AWS_SECRET_ACCESS_KEY'].nil? )
      end

      def self.parse( argv_opts = [] )

        options = Struct.new( *Options.default_options.keys ) do
          def future_verb
            copy ? 'copy' : 'move'
          end
          def present_verb
            copy ? 'coping' : 'moving'
          end
          def past_verb
            copy ? 'copied' : 'moved'
          end
        end.new( *Options.default_options.values )

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
              exit 2
            end
          end

          opts.on('-d', '--dest DIR', 'This is where the resulting files will be placed.') do |dir|
            dir = File.expand_path(dir.strip)
            if Dir.exists?(dir)
              options.dest = dir
            else
              puts "Whoops: '#{dir}' is not a directory" + ( dir =~ /^\d+$/ ? "... maybe you meant '-D #{dir}'?" : '' )
              exit 2
            end
          end

          opts.on('-D', '--days #',
                  "The number of days to keep in the current directory (default = #{Options.default_options[:days]}).") do |days|
            days = 0 if days.to_i < 0
            options.days = days.to_i
          end

          opts.separator ''
          opts.separator 'Additional Options:'

          opts.on('-c', '--[no-]copy', 'Copy the files rather than move them') { |c| options.copy = c }
          opts.on('-q', '--silent', 'Run quietly (same as --no-verbose)') { options.verbose = false }
          opts.on('-v', '--[no-]verbose', 'Run verbosely (default)') { |v| options.verbose = v }
          opts.on('--[no-]cloud',
                  'When set, files are also copied to the Cloud (default).',
                  'You must provide credentials in either ENV or ~/.aws/credentials') do |c|
            if c and have_cloud_credentials?
              options.cloud = true
            else
              puts 'Sorry, but you must first provide your AWS credentials to activate --cloud' if c
              options.cloud = false
            end
          end

          opts.separator ''
          opts.separator 'Informational:'

          opts.on('-h', '--help', 'Show this message') { puts VSTRING + "\n\n"; puts opts;  exit 255; }
          opts.on('-V', '--version', 'Show version (and exit)') { puts VSTRING;  exit 255; }
          opts.on('--dryrun', %q{Don't actually modify any files, just show what would happen}) { options.dryrun = true }
          opts.on('--debug', 'Run with debugging options (use with caution)') { options.debug = true }
        end

        opt_parser.parse!(argv_opts)
        options
      end

    end
  end
end
