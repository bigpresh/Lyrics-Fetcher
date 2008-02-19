package Lyrics::Fetcher::Cache;
# $Id$

use strict;
use warnings;

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


=head1 NAME

Lyrics::Fetcher::Cache - implement caching of lyrics

=head1 DESCRIPTION

This module deals with the caching of lyrics for Lyrics::Fetcher, using whatever
supported caching methods are available.

This is not intended to be used directly, it should be called solely by
Lyrics::Fetcher.  See L<Lyrics::Fetcher> for usage details.


=head1 INTERFACE

=over 4

=item get

Attempt to fetch from whatever cache module we managed to use

=cut

=item set

Attempt to store the value into the cache

=cut

=back


=head1 BUGS

There are no known bugs, if you catch one please let me know.


=head1 CONTACT AND COPYRIGHT

Copyright 2007-2008 David Precious <davidp@preshweb.co.uk> (CPAN Id: BIGPRESH)

All comments / suggestions / bug reports gratefully received (ideally use the
RT installation at http://rt.cpan.org/ but mail me direct if you prefer)

Previously:
Copyright 2003 Sir Reflog <reflog@mail15.com>. 
Copyright 2003 Zachary P. Landau <kapheine@hypa.net>


=head1 LICENSE

All rights reserved. This program is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.

=cut



1;
