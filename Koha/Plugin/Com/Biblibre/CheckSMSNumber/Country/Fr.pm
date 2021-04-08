package Koha::Plugin::Com::Biblibre::Country::CheckSMSNumber::Fr;

use Modern::Perl;


sub check {
    my ( $number, $option) = @_;

    if ($option eq '+33') {
        return _check33($number);
    }

    if ($option eq '0033') {
        return _check0033($number);
    }

    if ( $number =~ /^0[6-7]\d{8}$/ ) {
        return 1;
    }

    return 0;
}

sub _check33 {
    my ($number) = @_;

    if ( $number =~ /^\+33[6-7]\d{8}$/ ) {
        return 1;
    }

    return 0;
}

sub _check0033 {
    my ($number) = @_;

    if ( $number =~ /^0033[6-7]\d{8}$/ ) {
        return 1;
    }

    return 0;
}

sub transform {
    my ( $number, $option) = @_;

    if ($option eq '+33') {
        return _transform33($number);
    }

    if ($option eq '0033') {
        return _transform0033($number);
    }

    if ( $number =~ /^\+33\s*/ ) {
        $number =~ s/^\+33\s*/0/;
    }

    if ( $number =~ /^0*33\s*/ ) {
        $number =~ s/^0*33\s*/0/;
    }

    if ( $number =~ /^(0[6-7])[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})/ ) {
        return "$1$2$3$4$5";
    }

    return $number;
}

sub _transform33 {
    my ($number, $option) = @_;

    if ( $number =~ /^0033\s*/ ) {
        $number =~ s/^0033\s*/\+33/;
    }

    if ( $number =~ /^0([6-7])/ ) {
        $number =~ s/^0([6-7])/\+33$1/;
    }

    if ( $number =~ /^\+33[\-\s\.]*([6-7])[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})/ ) {
        return "+33$1$2$3$4$5";
    }

    return $number;
}

sub _transform0033 {
    my ($number, $option) = @_;

    if ( $number =~ /^\+33\s*/ ) {
        $number =~ s/^\+33\s*/0033/;
    }

    if ( $number =~ /^0([6-7])/ ) {
        $number =~ s/^0([6-7])/0033$1/;
    }

    if ( $number =~ /^0033[\-\s\.]*([6-7])[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})[\-\s\.]*(\d{2})/ ) {
        return "0033$1$2$3$4$5";
    }

    return $number;
}

1;