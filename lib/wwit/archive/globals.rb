module WWIT
  module Archive
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

    AWS_ACCESS_KEY_ID     = ENV['AWS_ACCESS_KEY_ID']
    AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY']
    AWS_REGION            = ENV['AWS_REGION']
    AWS_BUCKET            = ENV['AWS_BUCKET']
  end
end
