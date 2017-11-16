#!/usr/bin/env perl6

use v6;

sub is-overridden($package, &routine) {
    %*ENV<overrides>{$package.^name ~ '::' ~ &routine.name}:exists;
}

sub override(:$sig) {
    my $sub = %*ENV<overrides>{
        callframe(1).code.package.^name ~ '::' ~ callframe(1).code.name
    };
    # not using for inline modules
    # my $module = split('::', $sub)[0];
    # require ::("$module");
    &::($sub)(|$sig);
}

module FooCore {

    our proto sub bar(|) {*}
    multi bar(
        *$sig where { is-overridden $?PACKAGE, &?ROUTINE }) {
        override(:$sig);
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
