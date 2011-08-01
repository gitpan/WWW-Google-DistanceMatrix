#!perl

use strict; use warnings;
use WWW::Google::DistanceMatrix;
use Test::Warn;
use Test::More tests => 9;

my $google = WWW::Google::DistanceMatrix->new();

eval { $google->getDistance(); };
like($@, qr/Missing origins information./);

eval { $google->getDistance(o_addr => ['Address 1']); };
like($@, qr/Missing destinations information./);

eval { $google->getDistance(o_addr => 'Address 1'); };
like($@, qr/Missing destinations information./);

warning_is { eval { $google->getDistance(o_latlng => ['-1.50,']); }; } "ERROR: Invalid Latitude/Longitude [-1.50,].";

eval { $google->getDistance(o_latlng => '-1.50,'); }; 
like($@, qr/The 'o_latlng' parameter/);

eval { $google->getDistance(d_addr => ['Address 1']); };
like($@, qr/Missing origins information./);

eval { $google->getDistance(d_addr => 'Address 1'); };
like($@, qr/Missing origins information./);

warning_is { eval { $google->getDistance(d_latlng => ['-1.50,']); }; } "ERROR: Invalid Latitude/Longitude [-1.50,].";

eval { $google->getDistance(d_latlng => '-1.50,'); }; 
like($@, qr/The 'd_latlng' parameter/);