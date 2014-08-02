#!perl

use strict; use warnings;
use WWW::Google::DistanceMatrix;
use Test::More tests => 6;

eval { WWW::Google::DistanceMatrix->new(); };
like($@, qr/Missing required arguments: api_key/);

eval { WWW::Google::DistanceMatrix->new(api_key => 'API Key', avoid => 'tools'); };
like($@, qr/isa check for "avoid" failed/);

eval { WWW::Google::DistanceMatrix->new(api_key => 'API Key', sensor => 'trrue'); };
like($@, qr/isa check for "sensor" failed/);

eval { WWW::Google::DistanceMatrix->new(api_key => 'API Key', units => 'metricss'); };
like($@, qr/isa check for "units" failed/);

eval { WWW::Google::DistanceMatrix->new(api_key => 'API Key', mode => 'drivving'); };
like($@, qr/isa check for "mode" failed/);

eval { WWW::Google::DistanceMatrix->new(api_key => 'API Key', language => 'enn'); };
like($@, qr/isa check for "language" failed/);
