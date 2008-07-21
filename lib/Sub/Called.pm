package Sub::Called;

use warnings;
use strict;

use B;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(with_ampersand);

=head1 NAME

Sub::Called - get information about how the subroutine is called

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS


    use Sub::Called;

    sub test {
        if( Sub::Called::with_ampersand() ){
            print "you called this subroutine this way: &test\n",
                  "note that this disables prototypes!\n";
        }
    }

=head1 FUNCTIONS

=head2 with_ampersand

=cut

sub with_ampersand {
    my $sub  = (caller(2))[3] || "main"; 
    my $line = (caller(1))[2];
    
    my $svref = \&{$sub};
    my $obj   = B::svref_2object( $svref );
    
    my $op      = $sub eq 'main' ? B::main_start() : $obj->START;
    my $is_line = 0;
    my $retval  = 0;
    
    for(; $$op; $op = $op->next ){
        my $name    = $op->name;
        if( $name eq 'nextstate' ){
            $is_line = ( $op->line == $line );
        }
        
        next unless $is_line and $name eq 'entersub';
        
        my $priv = $op->private;
        
        if( $priv == 43 ){
            $retval = 1;
        }
        last;
    }

    return $retval;
}

=head1 LIMITATIONS

It seems that there are some problems with subroutine references.

This may not work:

  sub test2 {
      if( Sub::Called::with_ampersand() ){
          die "die hard";
      }
  };
    
  my $sub2 = main->can( 'test2' );
  &$sub2();

=head1 AUTHOR

Renee Baecker, C<< <module at renee-baecker.de> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-sub-called at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sub-Called>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sub::Called

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sub-Called>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Sub-Called>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Sub-Called>

=item * Search CPAN

L<http://search.cpan.org/dist/Sub-Called>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Renee Baecker, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Sub::Called
