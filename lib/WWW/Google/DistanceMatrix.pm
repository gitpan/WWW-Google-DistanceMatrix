package WWW::Google::DistanceMatrix;

$WWW::Google::DistanceMatrix::VERSION = '0.04';

use 5.006;
use JSON;
use Data::Dumper;

use WWW::Google::UserAgent;
use WWW::Google::DistanceMatrix::Result;
use WWW::Google::UserAgent::DataTypes qw($TrueOrFalse $XmlOrJson);
use WWW::Google::DistanceMatrix::Params qw(validate $Avoid $Units $Mode $Language $FIELDS);

use Moo;
use namespace::clean;
extends 'WWW::Google::UserAgent';

our $BASE_URL = 'https://maps.googleapis.com/maps/api/distancematrix';

=head1 NAME

WWW::Google::DistanceMatrix - Interface to Google Distance Matrix API.

=head1 VERSION

Version 0.04

=cut

has avoid    => (is => 'ro', isa => $Avoid);
has sensor   => (is => 'ro', isa => $TrueOrFalse, default  => sub { return 'false'   });
has units    => (is => 'ro', isa => $Units,       default  => sub { return 'metric'  });
has mode     => (is => 'ro', isa => $Mode,        default  => sub { return 'driving' });
has language => (is => 'ro', isa => $Language,    default  => sub { return 'en'      });
has output   => (is => 'ro', isa => $XmlOrJson,   default  => sub { return 'json'    });

=head1 DESCRIPTION

The Google Distance Matrix API  is a service that provides travel distance & time
for a matrix of origins and destinations.The information returned is based on the
recommended route between start & end points as calculated by the Google Maps API
&  consists  of  rows  containing duration and distance values for each pair. The
Distance Matrix API has the following limits in place:

=over 3

=item * 100 elements per query.

=item * 100 elements per 10 seconds.

=item * 2500 elements per 24 hour period.

=back

=head1 NOTE

Use  of  the  Distance  Matrix API must relate to the display of information on a
Google Map;  for  example  to determine origin-destination pairs that fall within
specific  driving  time  from  one another before requesting and displaying those
destinations on a map.Use of the service in an application that doesn't display a
Google map is prohibited.

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

    +----------+----------+------------------------------------------------+
    | key      | Description                                               |
    +----------+----------+------------------------------------------------+
    | o_addr   | One or more origin address(es).                           |
    | o_latlng | One or more origin latitude/longitude coordinate(s).      |
    | d_addr   | One or more destination address(es).                      |
    | d_latlng | One or more destination latitude/longitude coordinate(s). |
    +----------+----------+------------------------------------------------+

If you pass coordinates ensure that no space exists between the latitude/longitude values.

   use strict; use warnings;
   use WWW::Google::DistanceMatrix;

   my $api_key = 'Your API Key';
   my $google  = WWW::Google::DistanceMatrix->new( 'api_key' => $api_key );
   my $results = $google->getDistance({ o_addr => ['Vancouver+BC'], d_addr => ['Victoria+BC'] });
   foreach my $result (@$results) {
       print $result->as_string, "\n";
   }

=cut

sub getDistance {
    my ($self, $params) = @_;

    my $url      = $self->_url($params);
    my $response = $self->get($url);
    my $contents = from_json($response->{content});

    return _result($contents);
}

#
# PRIVATE METHODS
#

sub _url {
    my ($self, $params) = @_;

    my ($origins, $destinations) = ([], []);
    if (defined $params && ref($params) eq 'HASH') {
        if (defined $params->{'o_addr'} && (ref($params->{'o_addr'}) eq 'ARRAY')) {
            $FIELDS->{'o_addr'}->{check}->($params->{'o_addr'});
            push @$origins, @{$params->{'o_addr'}};
        }
        if (defined $params->{'o_latlng'} && (ref($params->{'o_latlng'}) eq 'ARRAY')) {
            $FIELDS->{'o_latlng'}->{check}->($params->{'o_latlng'});
            push @$origins, @{$params->{'o_latlng'}};
        }
        die "ERROR: Missing mandatory param: origins" unless scalar(@$origins);;

        if (defined $params->{'d_addr'} && (ref($params->{'d_addr'}) eq 'ARRAY')) {
            $FIELDS->{'d_addr'}->{check}->($params->{'d_addr'});
            push @$destinations, @{$params->{'d_addr'}};
        }
        if (defined $params->{'d_latlng'} && (ref($params->{'d_latlng'}) eq 'ARRAY')) {
            $FIELDS->{'d_latlng'}->{check}->($params->{'d_latlng'});
            push @$destinations, @{$params->{'d_latlng'}};
        }
        die "ERROR: Missing mandatory param: destinations" unless scalar(@$destinations);;
    }
    else {
        die "ERROR: Missing mandatory params: origins/destinations";
    }

    validate({ origins => 1, destinations => 1 },
             { origins => $origins, destinations => $destinations });

    my $keys = [];
    foreach (qw(sensor avoid units mode language)) {
        if (defined $self->{$_}) {
            my $_key = "$_=%" . $FIELDS->{$_}->{type};
            push @$keys, sprintf($_key, $self->{$_});
        }
    }

    my $url = sprintf("%s/%s?key=%s&%s",
                      $BASE_URL, $self->output, $self->api_key, join("&", @$keys));
    $url .= sprintf("&origins=%s", join("|", @{$origins}));
    $url .= sprintf("&destinations=%s", join("|", @{$destinations}));

    return $url;
}

sub _result {
    my ($data) = @_;

    my $results = [];
    my $o_index = 0;
    foreach my $origin (@{$data->{origin_addresses}}) {
        my $d_index = 0;
        foreach my $destination (@{$data->{destination_addresses}}) {
            my ($duration, $distance);
            if ($data->{rows}->[$o_index]->{elements}->[$d_index]->{status} eq 'OK') {
                $duration = $data->{rows}->[$o_index]->{elements}->[$d_index]->{duration}->{text};
                $distance = $data->{rows}->[$o_index]->{elements}->[$d_index]->{distance}->{text};
            }
            else {
                $duration = 'N/A';
                $distance = 'N/A';
            }

            push @$results,
            WWW::Google::DistanceMatrix::Result->new(
                origin      => $origin,
                destination => $destination,
                duration    => $duration,
                distance    => $distance);

            $d_index++;
        }
        $o_index++;
    }

    return $results;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please  report any bugs or feature requests to C<bug-www-google-distancematrix at
rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Google-DistanceMatrix>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Google::DistanceMatrix

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Google-DistanceMatrix>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Google-DistanceMatrix>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Google-DistanceMatrix>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Google-DistanceMatrix/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Mohammad S Anwar.

This  program  is  free software; you can redistribute it and/or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of WWW::Google::DistanceMatrix
