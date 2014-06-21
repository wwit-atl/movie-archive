module WWIT
  module Archive
    VERSION       = '1.5.1'
    IDENT         = 'movie-archive'
    AUTHOR        = 'Donovan C. Young'
    AEMAIL        = 'dyoung522@gmail.com'
    SUMMARY       = %q{Archives WWIT Show files}
    DESCRIPTION   = %q{Provides a runtime binary which can be called from terminal or cron.}
    HOMEPAGE      = "https://github.com/wwit-atl/#{IDENT}"
    LICENSE       = 'MIT'

    VSTRING       = "#{IDENT} v.#{VERSION} - #{AUTHOR}, 2014"

    KILOBYTE      = 2 ** 10   # Base 2 (1024)
    MEGABYTE      = 2 ** 20   # Base 2 (1024)
    GIGABYTE      = 2 ** 30   # Base 2 (1024)
    TERABYTE      = 10 ** 12  # Base 10 (1000)
    PETABYTE      = 10 ** 15  # Base 10 (1000)

  end
end
