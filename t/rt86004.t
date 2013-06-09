=pod

=encoding utf-8

=head1 PURPOSE

Test L<Type::Params> with more complex Dict coercion.

=head1 SEE ALSO

L<https://rt.cpan.org/Ticket/Display.html?id=86004>.

=head1 AUTHOR

Diab Jerius E<lt>djerius@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Diab Jerius.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;

BEGIN {
	package Types;
	use Type::Library
		-base,
		-declare => qw[ StrList ];
	use Type::Utils;
	use Types::Standard qw[ ArrayRef Str ];
	declare StrList, as ArrayRef [Str];
	coerce StrList, from Str, q { [$_] };
};

use Test::More;
use Test::Fatal;

use Type::Params qw[ validate compile ];
use Types::Standard -all;

sub a {
	validate(
		\@_,
		slurpy Dict [
			connect  => Optional [Bool],
			encoding => Optional [Str],
			hg       => Optional [Types::StrList],
		]
	);
}

sub b {
	validate(
		\@_,
		slurpy Dict [
			connect  => Optional [Bool],
			hg       => Optional [Types::StrList],
		]
	);
}

my $expect = {
	connect => 1,
	hg      => ['a'],
};

# 1
{
	my ( $opts, $e );
	
	$e = exception { ( $opts ) = a( connect => 1, hg => ['a'] ) }
		and diag $e;
		
	is_deeply( $opts, $expect, "StrList ArrayRef" );
}

# 2
{
	my ( $opts, $e );
	
	$e = exception { ( $opts ) = a( connect => 1, hg => 'a' ) }
		and diag $e;
	
	is_deeply( $opts, $expect, "StrList scalar" );
}

# 3
{
	my ( $opts, $e );
	
	$e = exception { ( $opts ) = b( connect => 1, hg => ['a'] ) }
		and diag $e;
	
	is_deeply( $opts, $expect, "StrList ArrayRef" );
}

# 4
{
	my ( $opts, $e );
	
	$e = exception { ( $opts ) = b( connect => 1, hg => 'a' ) }
		and diag $e;
	
	is_deeply( $opts, $expect, "StrList scalar" );
}

note do {
	require B::Deparse;
	"B::Deparse"->new->coderef2text(
		compile(
			slurpy Dict [
				connect  => Optional [Bool],
				encoding => Optional [Str],
				hg       => Optional [Types::StrList],
			],
		),
	);
};

done_testing;
