use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'WWW::Google::DistanceMatrix',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/WWW/Google/DistanceMatrix.pm',
    ABSTRACT_FROM => 'lib/WWW/Google/DistanceMatrix.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'WWW-Google-DistanceMatrix-*' },
    PREREQ_PM     => {
        'Test::More' => 0,
        'Test::Warn' => 0,
        'Readonly'    => 0,
        'Mouse'       => '0.93',
        'HTTP::Request'  => '1.40',
        'LWP::UserAgent' => '2.33',
        'MouseX::Params::Validate' => '0.01',        
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);