package Lyrics::Fetcher;

# Lyrics Fetcher
#
# Copyright (C) 2007 David Precious <davidp@preshweb.co.uk> (CPAN: BIGPRESH)
#
# Originally authored by and copyright (C) 2003 Sir Reflog <reflog@gmail.com>
# who kindly passed maintainership on to David Precious in Feb 2007
#
# Original idea:
# Copyright (C) 2003 Zachary P. Landau <kapheine@hypa.net>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# $Id$

use vars qw($VERSION $Error @FETCHERS);

$VERSION = '0.4.0';
$Error   = 'OK';      #return status string

use strict;

BEGIN {
    @FETCHERS = ();
    my $myname = __PACKAGE__;
    my $me     = $myname;
    $me =~ s/\:\:/\//g;
    foreach my $d (@INC) {
        chomp $d;
        if ( -d "$d/$me/" ) {
            local (*F_DIR);
            opendir( *F_DIR, "$d/$me/" );
            while ( my $b = readdir(*F_DIR) ) {
                next unless $b =~ /^(.*)\.pm$/;
                push @FETCHERS, $1;
            }
        }
    }

}

sub available_fetchers {
    return wantarray ? @FETCHERS : \@FETCHERS;
}

sub fetch {
    my ( $self, $artist, $title, $method ) = @_;

    my @tryfetchers;
    if ( $method && $method ne 'auto' ) {
        push @tryfetchers, $method;
    }
    else {
        push @tryfetchers, @FETCHERS;
    }

    return _fetch( $artist, $title, \@tryfetchers );

}    # end of sub fetch


# actual implementation method - takes params $artist, $title, and an
# arrayref of fetchers to try.  Returns the result from the first fetcher
# that succeeded, or undef if all fail.
sub _fetch {

    my ( $artist, $title, $fetchers ) = @_;

    if ( !$artist || !$title || ref $artist || ref $title ) {
        warn "_fetch called incorrectly";
        return;
    }

    if ( !$fetchers || ref $fetchers ne 'ARRAY' ) {
        warn "_fetch not given arrayref of fetchers to try";
        return;
    }

  fetcher:
    for my $fetcher (@$fetchers) {
        
        warn "Trying fetcher $fetcher";
    
        my $fetcherpkg = __PACKAGE__ . "::$fetcher";
        eval "require $fetcherpkg";
        if ($@) {
            warn "Failed to require $fetcherpkg";
            next fetcher;
        }

        # OK, we require()d this fetcher, try using it:
        $Error = 'OK';
        my $f = $fetcher->fetch( $artist, $title );
        if ( $Error eq 'OK' ) {
            return html2text($f);
        }
        else {
            next fetcher;
        }
    }

    # if we get here, we tried all fetchers we were asked to try, and none
    # of them worked.
    $Error = 'All fetchers failed to fetch lyrics';
    return undef;
}    # end of sub _fetch

sub html2text {
    my $str = shift;

    $str =~ s/\r/\n/g;
    $str =~ s/<br(.*?)>/\n/g;
    $str =~ s/&gt;/>/g;
    $str =~ s/&lt;/</g;
    $str =~ s/&amp;/&/g;
    $str =~ s/&quot;/\"/g;
    $str =~ s/<.*?>//g;
    $str =~ s/\n\n/\n/g;
    return $str;
}

1;

=head1 NAME

Lyrics::Fetcher - Perl extension to manage fetchers of song lyrics.

=head1 SYNOPSIS

      use Lyrics::Fetcher;

      print Lyrics::Fetcher->fetch("Pink Floyd","Echoes","LyricsTime");


=head1 DESCRIPTION

This module is a fetcher manager. It searches for modules in the 
Lyrics::Fetcher::*  name space and registers them as available fetchers.

The fetcher modules are called by Lyrics::Fetcher and they return song's lyrics 
in plain text form.

This module calls the respective Fetcher->fetch($$) method and returns the 
result.

In case of module error the Fetchers must return undef with the error 
description in $@.

In case of problems with lyrics' fetching, the error fill be returned in the 
$Lyrics::Fetcher::Error string.  If all goes well, it will have 'OK' in it.

The fetcher selection is made by the "method" parameter passed to the fetch() 
of this module.

The value of the "method" parameter must be a * part of the Lyrics::Fetcher::* 
fetcher package name. 

=head1 BUGS

There are no known bugs, if you catch one please let me know.

=head1 CONTACT AND COPYRIGHT

Copyright 2007 David Precious <davidp@preshweb.co.uk> (CPAN Id: BIGPRESH)

All comments / suggestions / bug reports gratefully received (ideally use the
RT installation at http://rt.cpan.org/ but mail me direct if you prefer)

Previously:
Copyright 2003 Sir Reflog <reflog@mail15.com>. 
Copyright 2003 Zachary P. Landau <kapheine@hypa.net>

All rights reserved. This program is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.

=cut
