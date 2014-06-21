require_relative '../../minitest_helper'

module WWIT
  module Archive
    class TestOptions < MiniTest::Test
      include TestSetup

      def setup
        @options = Options.parse()
      end

      def test_options_defaults
        assert_equal Options.default_options.hash, @options.hash
      end

      def test_options_verbose_default
        assert @options.verbose, 'Verbose should be ON by default'
      end

      def test_options_verbose
        assert Options.parse(['--verbose']).verbose, 'Verbose should be ON'
        refute Options.parse(['--no-verbose']).verbose, 'Verbose should be OFF'
      end

      def test_options_dryrun_default
        refute @options.dryrun, 'dryrun should be OFF by default'
      end

      def test_options_dryrun
        assert Options.parse(['--dryrun']).dryrun, '--dryrun should be ON'
      end

      def test_options_copy_default
        refute @options.copy, 'copy should be OFF by default'
      end

      def test_options_copy
        assert Options.parse(['--copy']).copy, 'Copy should be ON'
        refute Options.parse(['--no-copy']).copy, 'Copy should be OFF'
      end

      def test_options_debug_default
        refute @options.debug, 'debug should be OFF by default'
      end

      def test_options_debug
        assert Options.parse(['--debug']).debug, 'Debug should be ON'
      end

      def test_options_source
        assert_equal ['/tmp', '/var'], Options.parse(['-s /tmp', '--source=/var']).source
      end

      def test_options_invalid_source_prints_error
        assert_output /'\/foo' is not a directory/ do
          begin
            Options.parse(['-s /foo'])
          rescue SystemExit
          end
        end
      end

      def test_options_invalid_source_exits
        assert_raises SystemExit do
          capture_io { Options.parse(['-s /foo']) }
        end
      end

      def test_options_dest
        assert_equal '/tmp', Options.parse(['-d /tmp']).dest
      end

      def test_options_invalid_dest_prints_error
        assert_output /'\/foo' is not a directory/ do
          begin
            Options.parse(['-d /foo'])
          rescue SystemExit
          end
        end
      end

      def test_options_invalid_dest_exits
        assert_raises SystemExit do
          capture_io { Options.parse(['-d /foo']) }
        end
      end

      def test_options_version
        assert_output "#{IDENT} v.#{VERSION} - #{AUTHOR}\n" do
          begin
            Options.parse(['--version'])
          rescue SystemExit
          end
        end
      end

    end
  end
end

