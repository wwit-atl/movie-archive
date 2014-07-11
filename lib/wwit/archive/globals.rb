module WWIT
  module Archive
    require 'yaml'

    VERSION       = '2.0.0'
    IDENT         = 'movie-archive'
    AUTHOR        = 'Donovan C. Young'
    AEMAIL        = 'dyoung522@gmail.com'
    SUMMARY       = %q{Archives WWIT Show files}
    DESCRIPTION   = %q{Provides a runtime binary which can be called from terminal or cron.}
    HOMEPAGE      = "https://github.com/wwit-atl/#{IDENT}"
    LICENSE       = 'MIT'
    VSTRING       = "#{IDENT} v.#{VERSION} - #{AUTHOR}, 2014"

    KILOBYTE      = 2  ** 10  # Base 2  (1024)
    MEGABYTE      = 2  ** 20  # Base 2  (1048576)
    GIGABYTE      = 2  ** 30  # Base 2  (1073741824)
    TERABYTE      = 10 ** 12  # Base 10 (1000000000000)
    PETABYTE      = 10 ** 15  # Base 10 (1000000000000000)

    aws_cred_file = File.expand_path('~/.aws/credentials')
    if File.exists?(aws_cred_file)
      aws ||= YAML.load_file(aws_cred_file)
      AWS_ACCESS_KEY_ID     = aws['access_key_id']
      AWS_SECRET_ACCESS_KEY = aws['secret_access_key']
      AWS_BUCKET            = aws['bucket']
      AWS_REGION            = aws['region'] || 'us-east-1'
    else
      AWS_ACCESS_KEY_ID     = ENV['AWS_ACCESS_KEY_ID']
      AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY']
      AWS_BUCKET            = ENV['AWS_BUCKET']
      AWS_REGION            = ENV['AWS_REGION'] || 'us-east-1'
    end
  end
end
