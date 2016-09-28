package App::numseq;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

BEGIN {
    # this is a temporary trick to let Data::Sah use Scalar::Util::Numeric::PP
    # (SUNPP) instead of Scalar::Util::Numeric (SUN). SUNPP allows bigints while
    # SUN currently does not.
    $ENV{DATA_SAH_CORE_OR_PP} = 1;
}

our %SPEC;

$SPEC{numseq} = {
    v => 1.1,
    summary => 'Generate some number sequences',
    args => {
        name => {
            summary => 'Sequence name',
            schema => ['str*', {qin=>[
                'fib', 'fibonacci',
            ]}],
            req => 1,
            pos => 0,
        },
        start_numbers => {
            'x.name.is_plural' => 1,
            'x.name.singular' => 'start_number',
            schema => ['array*', of=>'int*'],
            pos => 1,
            greedy => 1,
        },
    },
    examples => [
        {
            summary => 'Generate Fibonacci numbers',
            src => '[[prog]] fib 1 2',
            src_plang => 'bash',
            'x.doc.show_result' => 0,
        },
    ],
    links => [
        {url => 'prog:seq'},
        {url => 'prog:seq-pericmd'},
        {url => 'prog:primes'},
        {url => 'prog:primes.pl'},
        {url => 'prog:primes-pericmd'},
    ],
};
sub numseq {
    use bigint;

    my %args = @_;

    my $name = $args{name};
    my $start_numbers = $args{start_numbers} // [];

    my $func;
    if ($name eq 'fib' || $name eq 'fibonacci') {
        return [400, "Please supply 2 starting numbers"]
            unless @$start_numbers == 2;
        my ($a, $b) = @$start_numbers;
        my $i = 0;
        $func = sub {
            $i++;
            my $res;
            if ($i == 1) {
                $res = $a;
            } elsif ($i == 2) {
                $res = $b;
            } else {
                $res = $a+$b;
                $a = $b;
                $b = $res;
            }
            return ref($res) eq 'Math::BigInt' ? $res->bstr : $res;
        };
    }
    return [200, "OK", $func, {stream=>1}];
}

1;
# ABSTRACT:

=head1 DESCRIPTION
