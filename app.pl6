#!/usr/bin/env perl6

use v6;

sub me {
    callframe(1).code.package.^name ~ '::' ~ callframe(1).code.name;
}

sub is-overridden($package, &routine) {
    %*ENV<overrides>{$package.^name ~ '::' ~ &routine.name}:exists;
}

sub override($subroutine, :$sig) {
    my $module = split('::', $subroutine)[0];
    &::($subroutine)(|$sig);
}

module FooCore {

    our proto sub bar(|) {*}
    multi bar(
        *$sig where { is-overridden $?PACKAGE, &?ROUTINE }) {
        override(%*ENV<overrides>{ me }, :$sig);
    }
    multi bar($var) {
        $var.uc;
    }

    our sub special($var) {
        bar($var);
    }

}

module FooCore::Extra {
    
    our sub thing($var) {
        # Isn't aware of the overrided bar.
        # Could also be called from another 
        # module.
        FooCore::bar($var);
    }
}

module FooOverride {
    our proto sub bar(|) {*}
    multi bar($var) {
        $var.chars;
    }
}

%*ENV<overrides> = %{
    'FooCore::bar' => 'FooOverride::bar'
};

say FooCore::bar('Hello, Perl 6');           # Output: 13
say FooCore::special('Hello, Perl 6');       # Output: 13

# Also uses the override version
say FooCore::Extra::thing('Hello, Perl 6');  # Output: 13
