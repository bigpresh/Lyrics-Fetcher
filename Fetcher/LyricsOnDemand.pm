#
# lyricsondemand - www.lyricsondemand.com implementation 
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

package Lyrics::Fetcher::LyricsOnDemand;
use strict;
use WWW::Mechanize;

our    $url = 'http://www.lyricsondemand.com';


my $agent = WWW::Mechanize->new();

sub fetch($$$){
    my($self,$artist, $title) = @_; 
    $agent->get($url);
    my($letter) = get_artist_letter($artist);
    $agent->follow(qr((?-xism:^$letter$)));
    if(grep { $_->text() =~ /$artist/ }@{$agent->links}) {
        $agent->follow(qr((?-xism:$artist)));
        if(grep { $_->text() =~ /$title/ }@{$agent->links}) {
    	    $agent->follow(qr((?-xism:$title)));
	}else{
	        $Lyrics::Fetcher::Error = 'Cannot find such title';
		return;
		    
	}
    }
    else{
	    $Lyrics::Fetcher::Error = 'Cannot find such artist';
	    return;
		
    }
    return $agent->content =~ /<b>$title Lyrics<\/b>.*?\n.*?\n(.*?)<\/font><\/p>/s;
	      
}

sub get_artist_letter{
    my($artist) = @_; 
    my($char) = split //,$artist;
    $char = uc $char;
    if ((ord($char) eq ord("0")) || (ord($char) >= ord("1") && ord($char) <= ord("9"))){
      $char = '#'
    }
    return "$char";
}
  

1;
