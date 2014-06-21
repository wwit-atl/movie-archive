module WWIT
  module Archive
    VERSION       = '1.5.0'
    IDENT         = 'wwit-archive'
    AUTHOR        = 'Donovan C. Young'
    AEMAIL        = 'dyoung522@gmail.com'
    SUMMARY       = %q{Archives WWIT Show files}
    DESCRIPTION   = %q{Provides a runtime binary which can be called from terminal or cron.}
    HOMEPAGE      = "http://github.com/dyoung522/#{IDENT}"
    LICENSE       = 'MIT'

    KILOBYTE      = 2 ** 10   # Base 2 (1024)
    MEGABYTE      = 2 ** 20   # Base 2 (1024)
    GIGABYTE      = 2 ** 30   # Base 2 (1024)
    TERABYTE      = 10 ** 12  # Base 10 (1000)
    PETABYTE      = 10 ** 15  # Base 10 (1000)

  end
end