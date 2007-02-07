# Lyrics Fetcher
#
# Copyright (C) 2003 Sir Reflog <reflog@mail15.com>
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

package Lyrics::Fetcher;
use vars qw($VERSION $Error);

$VERSION = '0.3.1';
$Error = 'OK'; #return status string

use strict;
use Data::Dumper;
use LWP::Simple qw(&get $ua);

BEGIN {
@__PACKAGE__::FETCHERS = ();
my $myname = __PACKAGE__;
my $me = $myname;
$me =~ s/\:\:/\//g;
foreach my $d (@INC) {
   chomp $d;
   if (-d "$d/$me/") { 
       local(*F_DIR);
       opendir(*F_DIR, "$d/$me/");
       while ( my $b = readdir(*F_DIR)) {
	       next unless $b =~ /^(.*)\.pm$/; 
	       push @__PACKAGE__::FETCHERS, $1;
       }
   }
}

}

sub available_fetchers {
  return wantarray ? @__PACKAGE__::FETCHERS : \@__PACKAGE__::FETCHERS;
}

sub fetch {
   my ($self, $artist, $title, $method)  = @_;

   unless ( grep /^$method$/, @__PACKAGE__::FETCHERS ) {
	$@ = "Need a valid method to use (".join(',',@__PACKAGE__::FETCHERS).")";
	return undef;
   }

   my $fetcher = __PACKAGE__."::$method";
   eval "require $fetcher";
   if ($@) { 
	return undef;
   }
   $Error = 'OK'; # reinit the error
   my($f) = $fetcher->fetch($artist, $title);
   
   return html2text($f);

}

sub html2text{
    my($str) = @_;
    
    $str =~ s/\r/\n/g;
    $str =~ s/<br(.*?)>/\n/g;
    $str =~ s/&gt;/>/g;
    $str =~ s/&lt;/</g;
    $str =~ s/&amp;/&/g;
    $str =~ s/&quot;/\"/g;
    $str =~ s/<.*?>//g;
    $str =~ s/\n\n/\n/g;
    return $str
}
				    
				    
				    

1;

=head1 NAME

Lyrics::Fetcher - Perl extension to manage fetchers of song lyrics.

=head1 SYNOPSIS

      use Lyrics::Fetcher;

      print Lyrics::Fetcher->fetch("Pink Floyd","Echoes","LyricsTime");


=head1 DESCRIPTION

This module is a fetcher manager. It searches for modules in the Lyrics::Fetcher::* 
name space and registers them as available fetchers.

The fetcher modules are called by Lyrics::Fetcher and they return song's lyrics in plain 
text form.

This module calls the respective Fetcher->fetch($$) method and returns the result.

In case of module error the Fetchers must return undef with the error description in $@.

In case of problems with lyrics' fetching, the error fill be returned in the $Lyrics::Fetcher::Error string.
If all goes well, it will have 'OK' in it.

The fetcher selection is made by the "method" parameter passed to the fetch() of this module.

The value of the "method" parameter must be a * part of the Lyrics::Fetcher::* fetcher package name. 

=head1 BUGS

There are no known bugs, if catch one please let me know.

=head1 CONTACT AND COPYRIGHT

Copyright 2003 Sir Reflog <reflog@mail15.com>. 
Copyright 2003 Zachary P. Landau <kapheine@hypa.net>
All rights reserved. This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=cut
