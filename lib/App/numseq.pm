package App::numseq;

# AUTHORITY
# DATE
# DIST
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
            schema => ['str*', {in=>[
                'fib', 'fibonacci',
                'squares',
                'fact', 'factorial',
            ]}],
            req => 1,
            pos => 0,
        },
        params => {
            'x.name.is_plural' => 1,
            'x.name.singular' => 'param',
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
    my $params = $args{params} // [];

    my $func;
    if ($name eq 'fib' || $name eq 'fibonacci') {
        return [400, "Please supply 2 starting numbers"]
            unless @$params == 2;
        my ($a, $b) = @$params;
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
    } elsif ($name eq 'squares') {
        #return [400, "Please supply at most one starting number"]
        #    unless @$params <= 1;
        return [400, "Extra parameters not allowed"] if @$params;
        my $i = $params->[0] // 1;
        $func = sub {
            my $res;
            $res = $i*$i;
            $i++;
            return ref($res) eq 'Math::BigInt' ? $res->bstr : $res;
        };
    } elsif ($name eq 'fact' || $name eq 'factorial') {
        #return [400, "Please supply at most one starting number"]
        #    unless @$params <= 1;
        return [400, "Extra parameters not allowed"] if @$params;
        my $i = $params->[0] // 1;
        my $res;
        $func = sub {
            if ($i == 1) {
                $res = $i;
            } else {
                $res *= $i;
            }
            $i++;
            return ref($res) eq 'Math::BigInt' ? $res->bstr : $res;
        };
    }
    return [200, "OK", $func, {stream=>1}];
}

1;
# ABSTRACT:

=head1 DESCRIPTION


=head1 SEE ALSO

These modules also have "numseq" in them, but they are only tangentially
related: L<NumSeq::Iter>, L<App::seq::numseq>, L<Sah::Schemas::NumSeq>.
