package Lyrics::Fetcher::Cache;
# $Id$

use strict;
use warnings;

# Caching code for Lyrics::Fetcher.
# Use Cache::Memory (from the Cache distribution) or Cache::SizeAwareMemoryCache
# (from the Cache::Cache distribution) to cache fetched lyrics in memory for a 
# while.
# This will be useful if Lyrics::Fetcher is being used many times in the same
# script; for example, if it's being used from MP3::Tag.

use vars qw($VERSION);
$VERSION = '0.0.1';


my $cache;
my $cache_size = 10000;  # maximum cache size, in bytes

# creating an instance of the different caching modules varies slightly,
# but once created they're used in the same way (->get() and ->set() calls).
my %caches = (
    'Cache::Memory' => sub {
        Cache::Memory->new(
            removal_strategy => 'Cache::RemovalStrategy::LRU',
            size_limit       => $cache_size,
        );
    },

    'Cache::SizeAwareMemoryCache' => sub {
        Cache::SizeAwareMemoryCache->new({ 
                                        'namespace' => 'LyricsFetcher',
                                        'max_size'  => $cache_size,
        });
    },
);

for my $cachemodule (keys %caches) {
    eval "require $cachemodule";
    if (!$@) {
        $cache = $caches{$cachemodule}->();
        last;
    }
}

   

sub get {
    return if !$cache;
    return $cache->get(join ':', @_);
}

sub set {
    return if !$cache;
    my ($artist, $title, $lyrics) = @_;
    return $cache->set(join(':', $artist, $title), $lyrics);
}

1;
