#!perl

use strict; use warnings;
use WWW::Google::DistanceMatrix;
use Test::More tests => 6;

eval { WWW::Google::DistanceMatrix->new(output => 'xmml'); };
like($@, qr/Attribute \(output\) does not pass the type constraint/);

eval { WWW::Google::DistanceMatrix->new(avoid => 'tools'); };
like($@, qr/Attribute \(avoid\) does not pass the type constraint/);

eval { WWW::Google::DistanceMatrix->new(sensor => 'trrue'); };
like($@, qr/Attribute \(sensor\) does not pass the type constraint/);

eval { WWW::Google::DistanceMatrix->new(unit => 'metrics'); };
like($@, qr/Attribute \(unit\) does not pass the type constraint/);

eval { WWW::Google::DistanceMatrix->new(mode => 'drivving'); };
like($@, qr/Attribute \(mode\) does not pass the type constraint/);

eval { WWW::Google::DistanceMatrix->new(language => 'enn'); };
like($@, qr/Attribute \(language\) does not pass the type constraint/);