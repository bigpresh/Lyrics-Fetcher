#
# LyricsTime - www.lyricstime.com implementation
#
# Original Version (Ruby):
# Copyright (C) 2003 Zachary P. Landau <kapheine@hypa.net>
# Perl Conversion:
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
package Lyrics::Fetcher::LyricsTime;

use LWP::Simple qw(&get $ua);

use strict;

our    $url = 'http://www.lyricstime.com';

  sub fetch($$$){
    my($self,$artist,$title) = @_;
    $ua->agent('Mozilla/5.0');
    my($song_url) = get_song_url($title,$artist);
    return unless $song_url;
    my($page) = get $song_url;
    return $page =~ /<td class="lyrics">.*?\n(.*?)<br><br>\n/s;
  }

  sub get_artist_list_url{
	  my($artist) = @_;
	  my($char) = split //,$artist;
	  $char = uc $char;
          if ((ord($char) eq ord("0")) || (ord($char) >= ord("1") && ord($char) <= ord("9"))){
		  $char = '0-9'
	  }
	  return "$url/$char/";
  }


  sub get_artist_url{
	  my($artist) = @_;
	  my($artist_url) = get_artist_list_url($artist);
	  return if !$artist_url;
	  my($page) = get  $artist_url;
	  my(@res) = $page =~ /<a href="\/artist\/(.*?)\/" title="(.*?) lyrics">(.*?)<\/a>/isg;
	  for(my $i=0;$i<$#res;$i+=3){
		  my($aurl, $aname) =  ($res[$i], $res[$i+1]);
		  if (lc($artist) eq lc($aname)){
			  return "$url/artist/$aurl/" ;
		  }
	  }

	  $Lyrics::Fetcher::Error = "get_artist_url : could not find #$artist";
	  return

  }

  
  sub get_song_url{
	  my($title,$artist) = @_;
	  my($artist_url) = get_artist_url($artist);
	  if(!$artist_url && $artist =~ /^The /i){ # try to fix 'the'
		  $artist =~ s/^The //i;
	          ($artist_url) = get_artist_url($artist);
	  }
	  return if !$artist_url;
	  my($page) = get $artist_url;
	  return if !$page;
	  my(@res) = $page =~ /href=\/lyrics\/(\d+).html>(.*?)<\/a><br>/isg;
	  for(my $i=0;$i<$#res;$i+=2){
		  my($aurl,$aname) =  ($res[$i], $res[$i+1]);
		  return "$url/lyrics/$aurl.html" if $aname =~ m/$title/i;
	  }
	  $Lyrics::Fetcher::Error =  "get_song_url could not find $title";
	  return;
  }


1;
