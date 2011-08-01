package WWW::Google::DistanceMatrix;

use Mouse;
use Mouse::Util::TypeConstraints;
use MouseX::Params::Validate;

use Carp;
use Readonly;
use Data::Dumper;

use HTTP::Request;
use LWP::UserAgent;

=head1 NAME

WWW::Google::DistanceMatrix - Interface to Google Distance Matrix API.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
Readonly my $BASE_URL => 'http://maps.googleapis.com/maps/api/distancematrix';
Readonly my $FORMAT   => { 'xml'     => 1, 'json'     => 1 };
Readonly my $AVOID    => { 'tolls'   => 1, 'highways' => 1 };
Readonly my $UNITS    => { 'metric'  => 1, 'imperial' => 1 };
Readonly my $SENSOR   => { 'true'    => 1, 'false'    => 1 };
Readonly my $MODE     => { 'driving' => 1, 'walking'  => 1, 'bicycling' => 1 };
Readonly my $LANGUAGE => 
{
    'ar'    => 1,
    'eu'    => 1,
    'bg'    => 1,
     'bn'    => 1,
    'ca'    => 1,
    'cs'    => 1,
    'da'    => 1,
    'de'    => 1,
    'de'    => 1,
    'el'    => 1,
    'en'    => 1,
    'en-AU' => 1,
    'en-GB' => 1,
    'es'    => 1,
    'eu'    => 1,
    'fa'    => 1,
    'fi'    => 1,
    'fil'   => 1,
    'fr'    => 1,
    'gl'    => 1,
    'gu'    => 1,
    'hi'    => 1,
    'hr'    => 1,
    'hu'    => 1,
    'id'    => 1,
    'it'    => 1,
    'iw'    => 1,
    'ja'    => 1,
    'kn'    => 1,
    'ko'    => 1,
    'lt'    => 1,
    'lv'    => 1,
    'ml'    => 1,
    'mr'    => 1,
    'nl'    => 1,
    'nn'    => 1,
    'no'    => 1,
    'or'    => 1,
    'pl'    => 1,
    'pt'    => 1,
    'pt-BR' => 1,
    'pt-PT' => 1,
    'rm'    => 1,
    'ro'    => 1,
    'ru'    => 1,
    'sk'    => 1,
    'sl'    => 1,
    'sr'    => 1,
    'sv'    => 1,
    'tl'    => 1,
    'ta'    => 1,
    'te'    => 1,
    'th'    => 1,
    'tr'    => 1,
    'uk'    => 1,
    'vi'    => 1,
    'zh-CN' => 1,
    'zh-TW' => 1,
};

=head1 DESCRIPTION

The Google Distance Matrix API  is a service that provides travel distance & time for a matrix
of origins and destinations.The information returned is based on the recommended route between 
start & end points as calculated by the Google Maps API & consists of rows containing duration 
and distance values for each pair. The Distance Matrix API has the following limits in place:

=over 3

=item * 100 elements per query.

=item * 100 elements per 10 seconds.

=item * 2500 elements per 24 hour period.

=back

=head1 NOTE

Use of the Distance Matrix API must relate to the display of information on a Google Map;  for
example to determine origin-destination pairs that fall within  specific driving time from one 
another before requesting and displaying those destinations on a map. Use of the service in an
application that doesn't display a Google map is prohibited.

=cut
subtype 'Address'
    => as 'Str';
subtype 'ArrayRefOfAddress'
    => as 'ArrayRef[Address]';
coerce 'ArrayRefOfAddress'
    => from 'Address'
    => via { [ $_ ] }
    => from 'ArrayRef[Str]'
    => via { [ map { $_ } @$_ ] };
    
subtype 'LatLng' 
    => as 'Str'
    => where { _validateLatLng($_) };
subtype 'ArrayRefOfLatLng'
    => as 'ArrayRef[LatLng]';
coerce 'ArrayRefOfLatLng'
    => from 'LatLng'
    => via { [ $_ ] }
    => from 'ArrayRef[Str]'
    => via { [ map { _coerceStrToLatLng($_) } @$_ ] };

type 'Format'   => where { exists $FORMAT->{lc($_)}   };
type 'Language' => where { exists $LANGUAGE->{lc($_)} };
type 'Mode'     => where { exists $MODE->{lc($_)}     };
type 'Avoid'    => where { exists $AVOID->{lc($_)}    };
type 'Units'    => where { exists $UNITS->{lc($_)}    };
type 'Sensor'   => where { exists $SENSOR->{lc($_)}   };
has  'avoid'    => (is => 'ro', isa => 'Avoid',          required => 0);
has  'sensor'   => (is => 'ro', isa => 'Sensor',         default  => 'false');
has  'unit'     => (is => 'ro', isa => 'Units',          default  => 'metric');
has  'mode'     => (is => 'ro', isa => 'Mode',           default  => 'driving');
has  'language' => (is => 'ro', isa => 'Language',       default  => 'en');
has  'output'   => (is => 'ro', isa => 'Format',         default  => 'json');
has  'browser'  => (is => 'rw', isa => 'LWP::UserAgent', default  => sub { return LWP::UserAgent->new(agent => 'Mozilla/5.0'); });

=head1 CONSTRUCTOR

The following list of optional parameters can be passed in to the constructor.

    +--------------+----------+--------------------------------------------------------------+
    | key          | Required |                                                              |
    +--------------+----------+--------------------------------------------------------------+
    | mode         | No       | Specifies what mode of transport to use when calculating     |
    |              |          | directions. Valid values are 'driving', 'walking' and        |
    |              |          | 'bicycling'. Default value is 'driving'.                     |
    | language     | No       | The language in which to return results. Default is 'en'.    |
    | avoid        | No       | Introduces restrictions to the route. Valid values: 'tolls'  |   
    |              |          | and 'highways'. Only one restriction can be specified.       |
    | units        | No       | Specifies the unit system to use when expressing distance as |
    |              |          | text. Valid values: 'metric' (default) and 'imperial'.       |
    | sensor       | No       | Indicates whether your application is using a sensor (such as|
    |              |          | a GPS locator) to determine the user's location. This value  |
    |              |          | must be either 'true' or 'false'. Default is 'false'.        | 
    +--------------+----------+--------------------------------------------------------------+

=head1 SUPPORTED LANGUAGES

    +-------+-------------------------+-------+-------+
    | Code  | Name                    |  v2   |  v3   |
    +-------+-------------------------+-------+-------+
    | ar    | ARABIC                  | Yes   |  Yes  |
    | eu    | BASQUE                  | No    |  Yes  |
    | bg    | BULGARIAN               | Yes   |  Yes  |
    | bn    | BENGALI                 | Yes   |  Yes  |
    | ca    | CATALAN                 | Yes   |  Yes  |
    | cs    | CZECH                   | Yes   |  Yes  |
    | da    | DANISH                  | Yes   |  Yes  |
    | de    | GERMAN                  | Yes   |  Yes  |
    | de    | GERMAN                  | Yes   |  Yes  |
    | el    | GREEK                   | Yes   |  Yes  |
    | en    | ENGLISH                 | Yes   |  Yes  |
    | en-AU | ENGLISH (AUSTRALIAN)    | No    |  Yes  |
    | en-GB | ENGLISH (GREAT BRITAIN) | No    |  Yes  |
    | es    | SPANISH                 | Yes   |  Yes  |
    | eu    | BASQUE                  | Yes   |  Yes  |
    | fa    | FARSI                   | No    |  Yes  |
    | fi    | FINNISH                 | Yes   |  Yes  |
    | fil   | FILIPINO                | Yes   |  Yes  |
    | fr    | FRENCH                  | Yes   |  Yes  |
    | gl    | GALICIAN                | Yes   |  Yes  |
    | gu    | GUJARATI                | Yes   |  Yes  |
    | hi    | HINDI                   | Yes   |  Yes  |
    | hr    | CROATIAN                | Yes   |  Yes  |
    | hu    | HUNGARIAN               | Yes   |  Yes  |
    | id    | INDONESIAN              | Yes   |  Yes  |
    | it    | ITALIAN                 | Yes   |  Yes  |
    | iw    | HEBREW                  | Yes   |  Yes  |
    | ja    | JAPANESE                | Yes   |  Yes  |
    | kn    | KANNADA                 | Yes   |  Yes  |
    | ko    | KOREAN                  | Yes   |  Yes  |
    | lt    | LITHUANIAN              | Yes   |  Yes  |
    | lv    | LATVIAN                 | Yes   |  Yes  |
    | ml    | MALAYALAM               | Yes   |  Yes  |
    | mr    | MARATHI                 | Yes   |  Yes  |
    | nl    | DUTCH                   | Yes   |  Yes  |
    | nn    | NORWEGIAN NYNORSK       | Yes   |  No   |
    | no    | NORWEGIAN               | Yes   |  Yes  |
    | or    | ORIYA                   | Yes   |  No   |
    | pl    | POLISH                  | Yes   |  Yes  |
    | pt    | PORTUGUESE              | Yes   |  Yes  |
    | pt-BR | PORTUGUESE (BRAZIL)     | Yes   |  Yes  |
    | pt-PT | PORTUGUESE (PORTUGAL)   | Yes   |  Yes  |
    | rm    | ROMANSCH                | Yes   |  No   |
    | ro    | ROMANIAN                | Yes   |  Yes  |
    | ru    | RUSSIAN                 | Yes   |  Yes  |
    | sk    | SLOVAK                  | Yes   |  Yes  |
    | sl    | SLOVENIAN               | Yes   |  Yes  |
    | sr    | SERBIAN                 | Yes   |  Yes  |
    | sv    | SWEDISH                 | Yes   |  Yes  |
    | tl    | TAGALOG                 | No    |  Yes  |
    | ta    | TAMIL                   | Yes   |  Yes  |
    | te    | TELUGU                  | Yes   |  Yes  |
    | th    | THAI                    | Yes   |  Yes  |
    | tr    | TURKISH                 | Yes   |  Yes  |
    | uk    | UKRAINIAN               | Yes   |  Yes  |
    | vi    | VIETNAMESE              | Yes   |  Yes  |
    | zh-CN | CHINESE (SIMPLIFIED)    | Yes   |  Yes  |
    | zh-TW | CHINESE (TRADITIONAL)   | Yes   |  Yes  |
    +-------+-------------------------+-------+-------+

=head1 METHODS

=head2 getDistance()

Returns the distance matrix in the desired output format (json/xml) from the set of origins to
the set of destinations. Following parameters can be passed in:

    +----------+----------+--------------------------------------------------------------+
    | key      | Description                                                             |
    +----------+----------+--------------------------------------------------------------+
    | o_addr   | One or more origin address(es).                                         |
    | o_latlng | One or more origin latitude/longitude coordinate(s).                    |
    | d_addr   | One or more destination address(es).                                    |
    | d_latlng | One or more destination latitude/longitude coordinate(s).               |
    +----------+----------+--------------------------------------------------------------+

If you pass coordinates ensure that no space exists between the latitude/longitude values.

    use strict; use warnings;
    use WWW::Google::DistanceMatrix;

    my $google = WWW::Google::DistanceMatrix->new();
    print $google->getDistance(o_addr => 'Bobcaygeon+ON',
                               d_addr => 'Darling+Harbour+NSW+Australia');
                               
    print $google->getDistance(o_addr => '41.43206,-81.38992',
                               d_addr => 'Darling+Harbour+NSW+Australia');
                           
    print $google->getDistance(o_addr => ['Vancouver+BC', 'Seattle'],
                               d_addr => ['San+Francisco', 'Victoria+BC']);                                                          

=cut

sub getDistance
{
    my $self = shift;
    my %param = validated_hash(\@_,
                'o_addr'   => { isa => 'ArrayRefOfAddress', coerce => 1, optional => 1 },
                'd_addr'   => { isa => 'ArrayRefOfAddress', coerce => 1, optional => 1 },
                'o_latlng' => { isa => 'ArrayRefOfLatLng',  coerce => 1, optional => 1 },
                'd_latlng' => { isa => 'ArrayRefOfLatLng',  coerce => 1, optional => 1 },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);
                
    croak("Missing origins information.\n") 
        unless (exists($param{'o_addr'}) || exists($param{'o_latlng'}));
    croak("Missing destinations information.\n") 
        unless (exists($param{'d_addr'}) || exists($param{'d_latlng'}));
        
    my ($origins, $destinations);
    my ($browser, $url, $request, $response, $content);
    
    map { push @{$origins}, $_ } @{$param{'o_addr'}}   if defined $param{'o_addr'};
    map { push @{$origins}, $_ } @{$param{'o_latlng'}} if defined $param{'o_latlng'};
    map { push @{$destinations}, $_ } @{$param{'d_addr'}}   if defined $param{'d_addr'};
    map { push @{$destinations}, $_ } @{$param{'d_latlng'}} if defined $param{'d_latlng'};
    
    $browser = $self->browser;
    $browser->env_proxy;
    $url = sprintf("%s/%s", $BASE_URL, $self->output);
    $url.= sprintf("?origins=%s", join("|", @{$origins}));
    $url.= sprintf("&destinations=%s", join("|", @{$destinations}));
    $url.= sprintf("&sensor=%s", $self->sensor);
    $url.= sprintf("&avoid=%s", $self->avoid) if $self->avoid;
    $url.= sprintf("&unit=%s", $self->unit);
    $url.= sprintf("&mode=%s", $self->mode);
    $url.= sprintf("&language=%s", $self->language);
    
    $request  = HTTP::Request->new(GET => $url);
    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return $content;        
}

sub _validateLatLng
{
    my $location = shift;
    my ($lat, $lng);
    return 0 unless ( defined($location)
                      &&
                      ($location =~ /\,/)
                      &&
                      ((($lat, $lng) = split/\,/,$location,2)
                       &&
                       (($lat =~ /^\-?\d+\.?\d+$/)
                        &&
                        ($lng =~ /^\-?\d+\.?\d+$/))));
    return 1;                        
}

sub _coerceStrToLatLng
{
    my $data = shift;
    return $data if _validateLatLng($data);
    warn("ERROR: Invalid Latitude/Longitude [$data].");
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-google-distancematrix at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Google-DistanceMatrix>.
I will be notified and then you'll automatically be notified of progress on your bug as I make 
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Google::DistanceMatrix

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Google-DistanceMatrix>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Google-DistanceMatrix>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Google-DistanceMatrix>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Google-DistanceMatrix/>

=back

=head1 LICENSE AND COPYRIGHT

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__PACKAGE__->meta->make_immutable;
no Mouse; # Keywords are removed from the WWW::Google::DistanceMatrix package
no Mouse::Util::TypeConstraints;

1; # End of WWW::Google::DistanceMatrix