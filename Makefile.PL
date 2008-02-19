use 5.005000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lyrics::Fetcher',
    VERSION_FROM      => 'lib/Lyrics/Fetcher.pm', # finds $VERSION
    PREREQ_PM         => {  },
    NO_META           => 1,
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lyrics/Fetcher.pm',
       AUTHOR         => 'David Precious <davidp@preshweb.co.uk>') : ()),
);
