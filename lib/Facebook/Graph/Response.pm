package Facebook::Graph::Response;

use Any::Moose;
use JSON;

has response => (
    is      => 'ro',
    required=> 1,
);

has as_string => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->response->content;
    },
);

has as_json => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $response = $self->response;
        if ($response->is_success) {
            return $response->content;
        }
        else {
            my $message = $response->message;
            my $error = eval { JSON->new->decode($response->content) };
            my $type = 'Unknown';
            unless ($@) {
                $message = $error->{error}{type} . ' - ' . $error->{error}{message};
                $type = $error->{error}{type};
            }
            return JSON->new->encode($error);
#            confess [$response->code, 'Could not execute request ('.$response->request->uri->as_string.'): '.$message, $type];
        }
    },
);

has as_hashref => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return JSON->new->decode($self->as_json);
    },
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Facebook::Graph::Response - Handling of a Facebook::Graph response documents.

=head1 DESCRIPTION

You'll be given one of these as a result of calling the C<request> method on a C<Facebook::Graph::Query> or others.


=head1 METHODS

Returns the response as a string. Does not throw an exception of any kind.

=head2 as_json ()

Returns the response from Facebook as a JSON string.

=head2 as_hashref ()

Returns the response from Facebook as a hash reference.

=head2 as_string ()

No processing what so ever. Just returns the raw body string that was received from Facebook.

=head2 response ()

Direct access to the L<HTTP::Response> object.

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


