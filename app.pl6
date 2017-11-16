#!/usr/bin/env perl6

use v6;

use lib 'lib';

sub me is export {
    callframe(1).code.package.^name ~ '::' ~ callframe(1).code.name;
}

sub is-overridden($package, &routine) is export {
    %*ENV<overrides>{$package.^name ~ '::' ~ &routine.name}:exists;
}

sub override($subroutine, :$sig) is export {
    my $module = split('::', $subroutine)[0];
    &::($subroutine)(|$sig);
}

module FooCore {

    our proto sub bar(|) {*}
    multi bar(
        *$sig where { is-overridden $?PACKAGE, &?ROUTINE }) {
        override(%*ENV<overrides>{ me }, :$sig);
    }
    multi bar(
        $var
    ) {
        return $var.uc;
    }

    our sub special($var) {
        bar($var);
    }

}

module FooCore::Extra {
    
    our sub thing($var) {
        FooCore::bar($var);
    }
}

module FooOverride {
    our proto sub bar(|) {*}
    multi bar($var) {
        return $var.chars;
    }
}

%*ENV<overrides> = %{
    'FooCore::bar' => 'FooOverride::bar'
};

say FooCore::bar('Hello, Perl 6');
say FooCore::special('Hello, Perl 6');

# Also uses the override version
say FooCore::Extra::thing('Hello, Perl 6');

