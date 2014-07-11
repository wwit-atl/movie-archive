require_relative '../../minitest_helper'

module WWIT
  module Archive
    class TestOptions < MiniTest::Test
      include TestSetup

      def setup
        @options = Options.parse()
      end

      def test_options_defaults
        Options.default_options.each_key do |key|
          assert_equal Options.default_options[key], @options[key]
        end
      end

      def test_options_verbose_default
        assert @options.verbose, 'Verbose should be ON by default'
      end

      def test_options_actions
        assert_equal 'move', @options.future_verb
        assert_equal 'moved', @options.past_verb
        assert_equal 'moving', @options.present_verb
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
        assert_output "#{VSTRING}\n" do
          begin
            Options.parse(['--version'])
          rescue SystemExit
          end
        end
      end

      def test_cloud
        have_file = File.exists?(File.expand_path('~/.aws/credentials'))
        have_env  = !( ENV['AWS_ACCESS_KEY_ID'].nil? or ENV['AWS_SECRET_ACCESS_KEY'].nil? )
        assert_equal (have_file or have_env), Options.have_cloud_credentials?

        if Options.have_cloud_credentials?
          assert @options.cloud, 'Cloud should be ON by default'
        else
          refute @options.cloud, 'Cloud should be OFF by default without creds'
        end

        assert Options.parse(['--cloud']).cloud, 'Cloud should be ON' if Options.have_cloud_credentials?
        refute Options.parse(['--no-cloud']).cloud, 'Cloud should be OFF'
      end

    end
  end
end

