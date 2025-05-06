use 5.010001;
use strict;
use warnings;
use XSLoader ();

package Type::Tiny::XS;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.016';

__PACKAGE__->XSLoader::load($VERSION);

use Scalar::Util qw(refaddr);

my %names = (map +( $_ => __PACKAGE__ . "::$_" ), qw/
	Any ArrayRef Bool ClassName CodeRef Defined
	FileHandle GlobRef HashRef Int Num Object
	Ref RegexpRef ScalarRef Str Undef Value
	PositiveInt PositiveOrZeroInt NonEmptyStr
	Map Tuple Enum AnyOf AllOf
/);
$names{Item} = $names{Any};

my %coderefs;
sub _know {
	my ($coderef, $type) = @_;
	$coderefs{refaddr($coderef)} = $type;
}

sub is_known {
	my $coderef = shift;
	$coderefs{refaddr($coderef)};
}

for (reverse sort keys %names) {
	no strict qw(refs);
	_know \&{$names{$_}}, $_;
}

my $id = 0;

sub get_coderef_for {
	my $type = $_[0];
	
	return do {
		no strict qw(refs);
		\&{ $names{$type} }
	} if exists $names{$type};
	
	my $made;
	
	if ($type =~ /^ArrayRef\[(.+)\]$/) {
		my $child = get_coderef_for($1) or return;
		$made = _parameterize_ArrayRef_for($child);
	}
	
	elsif ($type =~ /^HashRef\[(.+)\]$/) {
		my $child = get_coderef_for($1) or return;
		$made = _parameterize_HashRef_for($child);
	}
	
	elsif ($type =~ /^Map\[(.+),(.+)\]$/) {
		my @children;
		if (eval { require Type::Parser }) {
			@children = map scalar(get_coderef_for($_)), _parse_parameters($type);
		}
		else {
			push @children, get_coderef_for($1);
			push @children, get_coderef_for($2);
		}
		@children==2 or return;
		defined or return for @children;
		$made = _parameterize_Map_for( \@children );
	}
	
	elsif ($type =~ /^(AnyOf|AllOf|Tuple)\[(.+)\]$/) {
		my $base = $1;
		my @children =
			map scalar(get_coderef_for($_)),
			(eval { require Type::Parser })
				? _parse_parameters($type)
				: split(/,/, $2);
		defined or return for @children;
		my $maker = __PACKAGE__->can("_parameterize_${base}_for");
		$made = $maker->(\@children) if $maker;
	}
	
	elsif ($type =~ /^Maybe\[(.+)\]$/) {
		my $child = get_coderef_for($1) or return;
		$made = _parameterize_Maybe_for($child);
	}
	
	elsif ($type =~ /^InstanceOf\[(.+)\]$/) {
		my $class = $1;
		return unless Type::Tiny::XS::Util::is_valid_class_name($class);
		$made = Type::Tiny::XS::Util::generate_isa_predicate_for($class);
	}
	
	elsif ($type =~ /^HasMethods\[(.+)\]$/) {
		my $methods = [ sort(split /,/, $1) ];
		/^[^\W0-9]\w*$/ or return for @$methods;
		$made = Type::Tiny::XS::Util::generate_can_predicate_for($methods);
	}
	
	elsif ($type =~ /^Enum\[(.+)\]$/) {
		my $strings = [ sort(split /,/, $1) ];
		$made = _parameterize_Enum_for($strings);
	}
	
	if ($made) {
		no strict qw(refs);
		my $slot = sprintf('%s::AUTO::TC%d', __PACKAGE__, ++$id);
		$names{$type} = $slot;
		_know($made, $type);
		*$slot = $made;
		return $made;
	}
	
	return;
}

sub get_subname_for {
	my $type = $_[0];
	get_coderef_for($type) unless exists $names{$type};
	$names{$type};
}

sub _parse_parameters {
	my $got = Type::Parser::parse(@_);
	$got->{params} or return;
	_handle_expr($got->{params});
}

sub _handle_expr {
	my $e = shift;
	
	if ($e->{type} eq 'list') {
		return map _handle_expr($_), @{$e->{list}};
	}
	if ($e->{type} eq 'parameterized') {
		my ($base) = _handle_expr($e->{base});
		my @params = _handle_expr($e->{params});
		return sprintf('%s[%s]', $base, join(q[,], @params));
	}
	if ($e->{type} eq 'expression' and $e->{op}->type eq Type::Parser::COMMA()) {
		return _handle_expr($e->{lhs}), _handle_expr($e->{rhs})
	}
	if ($e->{type} eq 'primary') {
		return $e->{token}->spelling;
	}
	
	'****';
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Type::Tiny::XS - provides an XS boost for some of Type::Tiny's built-in type constraints

=head1 SYNOPSIS

   use Types::Standard qw(Int);

=head1 DESCRIPTION

This module is optionally used by L<Type::Tiny> 0.045_03 and above
to provide faster, C-based implementations of some type constraints.
(This package has only core dependencies, and does not depend on
Type::Tiny, so other data validation frameworks might also consider
using it!)

Only the following three functions should be considered part of the
supported API:

=over

=item C<< Type::Tiny::XS::get_coderef_for($type) >>

Given a supported type constraint name, such as C<< "Int" >>, returns
a coderef that can be used to validate a parameter against this
constraint.

Returns undef if this module cannot provide a suitable coderef.

=item C<< Type::Tiny::XS::get_subname_for($type) >>

Like C<get_coderef_for> but returns the name of such a sub as a string.

Returns undef if this module cannot provide a suitable sub name.

=item C<< Type::Tiny::XS::is_known($coderef) >>

Returns true if the coderef was provided by Type::Tiny::XS.

=back

In addition to the above functions, the subs returned by
C<get_coderef_for> and C<get_subname_for> are considered part of the
"supported API", but only for the lifetime of the Perl process that
returned them.

To clarify, if you call C<< get_subname_for("ArrayRef[Int]") >> in a
script, this will return the name of a sub. That sub (which can be used
to validate arrayrefs of integers) is now considered part of the
supported API of Type::Tiny::XS until the script finishes running. Next
time the script runs, there is no guarantee that the sub will continue
to exist, or continue to do the same thing.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Type-Tiny-XS>.

=head1 SEE ALSO

L<Type::Tiny>, L<Types::Standard>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt> forked all this from
L<Mouse::Util::TypeConstraints>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2014 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

