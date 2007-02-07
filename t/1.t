use Test::More 'no_plan';

use_ok('Lyrics::Fetcher');

require_ok('Lyrics::Fetcher::AstraWeb');
require_ok('Lyrics::Fetcher::LyricsNet');
require_ok('Lyrics::Fetcher::LyricsOnDemand');
require_ok('Lyrics::Fetcher::LyricsTime');

foreach ("AstraWeb", "LyricsNet", "LyricsOnDemand", "LyricsTime"){
diag("Checking for Metallica's Unforgiven on $_");
my($t) =  Lyrics::Fetcher->fetch("Metallica","Unforgiven",$_);
ok($Lyrics::Fetcher::Error eq 'OK', $Lyrics::Fetcher::Error);
}
