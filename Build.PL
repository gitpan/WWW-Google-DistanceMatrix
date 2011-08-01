use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign              => 1,
    module_name       => 'WWW::Google::DistanceMatrix',
    license           => 'perl',
    dist_author       => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from => 'lib/WWW/Google/DistanceMatrix.pm',
    add_to_cleanup    => [ 'WWW-Google-DistanceMatrix-*' ],    
    build_requires    => {
        'Test::More' => 0,
        'Test::Warn' => 0,
        'Readonly'    => 0,
        'Mouse'       => '0.93',
        'HTTP::Request'  => '1.40',
        'LWP::UserAgent' => '2.33',
        'MouseX::Params::Validate' => '0.01',
    },
);

$builder->create_build_script();