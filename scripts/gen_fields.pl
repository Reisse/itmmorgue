#!/usr/bin/perl
# Made by kk

use strict;
use warnings;

my @f = ();

s/\n//, push @f, [split(//, $_)] while <>;
my @nf = ();

for my $i (0..@f-1) {
  for my $j (0..@{$f[$i]}-1) {
      $nf[$i][$j] = 0;
      for my $k ($i-1..$i+1) {
        $nf[$i][$j] += ($f[$k][$_] // '.') eq '"' for $j-1..$j+1;
      }
      $nf[$i][$j] -= $f[$i][$j] eq '"';
  }
}

for my $i (0..@f-1) {
  for my $j (0..@{$f[$i]}-1) {
    $f[$i][$j] = $nf[$i][$j] >= 5 ? '"' : '.' if $f[$i][$j] =~ /[".]/;
  }
}

$\ = "\n";
print join '', @$_ for @f;

