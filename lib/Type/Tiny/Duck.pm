package Type::Tiny::Duck;

use 5.008001;
use strict;
use warnings;

BEGIN {
	$Type::Tiny::Duck::AUTHORITY = 'cpan:TOBYINK';
	$Type::Tiny::Duck::VERSION   = '0.001';
}

use Scalar::Util qw< blessed >;

sub _confess ($;@)
{
	require Carp;
	@_ = sprintf($_[0], @_[1..$#_]) if @_ > 1;
	goto \&Carp::confess;
}

use base "Type::Tiny";

sub new {
	my $proto = shift;
	my %opts = @_;
	_confess "need to supply list of methods" unless exists $opts{methods};
	$opts{methods} = [$opts{methods}] unless ref $opts{methods};
	return $proto->SUPER::new(%opts);
}

sub methods     { $_[0]{methods} }
sub inlined     { $_[0]{inlined} ||= $_[0]->_build_inlined }

sub has_inlined { !!1 }

sub _build_constraint
{
	my $self    = shift;
	my @methods = @{$self->methods};
	return sub { blessed($_[0]) and not grep(!$_[0]->can($_), @methods) };
}

sub _build_inlined
{
	my $self = shift;
	my $var  = $_[0];
	my @methods = @{$self->methods};
	local $" = q{ };
	return qq{ blessed($var) and not grep(!$var->can(\$_), qw/@methods/) };
}

sub _build_message
{
	my $self = shift;
	return sub { sprintf 'value "%s" did not pass type constraint', $_[0] } if $self->is_anon;
	my $name = "$self";
	return sub { sprintf 'value "%s" did not pass type constraint "%s"', $_[0], $name };
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Type::Tiny::Duck - type constraints based on the "can" method

=head1 DESCRIPTION

Type constraints of the general form C<< { $_->can("method") } >>.

This package inherits from L<Type::Tiny>; see that for most documentation.
Major differences are listed below:

=head2 Attributes

=over

=item C<methods>

An arrayref of method names.

=item C<constraint>

Unlike Type::Tiny, you should generally I<not> pass a constraint to the
constructor. Instead rely on the default.

=item C<inlined>

Unlike Type::Tiny, you should generally I<not> pass an inlining coderef to
the constructor. Instead rely on the default.

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Type-Tiny>.

=head1 SEE ALSO

L<Type::Tiny::Manual>.

L<Type::Tiny>.

L<Moose::Meta::TypeConstraint::DuckType>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
