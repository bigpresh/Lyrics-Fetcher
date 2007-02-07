#
# LyricsNet re-implementation
#
# Copyright (C) 2003 Sir Reflog <reflog@mail15.com>
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
#

package Lyrics::Fetcher::LyricsNet;

use strict;
use WWW::Mechanize;
use URI::URL;

sub fetch($$$){
    my($self,$artist, $title) = @_;
    my $agent = WWW::Mechanize->new();
    my($sartist) = join ("+", split(/ /, $artist));
    my($stitle) = join ("+", split(/ /, $title));
    $agent->get("http://www.lyrics.net.ua/search.php?q=$sartist+$stitle");
    if(grep { $_->text() =~ /$title/ }@{$agent->links}) {
	$agent->follow_link( text => $title, n => 1 );
    }else{
    $Lyrics::Fetcher::Error = 'Cannot find such title';
    return;
    }
    return ($agent->content =~ /<p class=text>(.*?)<\/p>/s)
}

1;