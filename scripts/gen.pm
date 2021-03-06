#!/usr/bin/perl
# made by: KorG

package gen;

use strict;
use v5.18;
use warnings;
no warnings 'experimental';
use utf8;
binmode STDOUT, ':utf8';
srand;

my (@WORLD, @SIZE);
my $level = 0;
my $qr_free = qr'[."^]';

# Get or set current level
sub level { $level = $_[1] // $level }

# Get or set current free regex
sub free_regex {
   my $regex = $_[1] // '[."^]';

   $qr_free = qr"$regex";
}

# (internal) Return a reference to the whole world
sub _get_world_ref { \@WORLD }

# Return a reference to the level
# opt. arg: level number
sub get_level_ref {
   my $curr = $_[1] // $level;

   $WORLD[$curr] // ($WORLD[$curr] = [])
}

# Print the level to stdout
# opt. arg: level number
sub print_level {
   my $curr = $_[1] // $level;

   do { print @$_, "\n" } for @{$WORLD[$level]};
}

# Slurp the level from stdin
# opt. arg: level number
sub read_level {
   my $curr = $_[1] // $level;

   my ($T, $H, $W) = get_level_ref();

   $/="";
   @{$T->[$H++]} = split // for split /\n/, <>;
   $W = @{$T->[0]};

   $SIZE[$curr] = {
      height => $H,
      width  => $W,
   };

   $T;
}

# Just return size[2] of the level
# opt. arg: level number
sub get_size {
   my $curr = $_[1] // $level;

   ($SIZE[$curr]->{height}, $SIZE[$curr]->{width});
}

# Recalculate the size of the level and return size[2]
# opt. arg: level number
sub update_size {
   my $curr = $_[1] // $level;

   $SIZE[$curr]->{height} = @{$WORLD[$curr]};
   $SIZE[$curr]->{width}  = @{$WORLD[$curr][0]};

   ($SIZE[$curr]->{height}, $SIZE[$curr]->{width});
}

# Overlay arg3 array over current level at arg1 x arg2 position.
# arg1: X coordinate of left upper corner
# arg2: Y
# arg3: building being built (array ref)
sub overlay_unsafe {
   my ($self, $y, $x, $building) = @_;
   my $h = @$building;
   my $T = get_level_ref();

   while ($h > 0) {
      my $ty = $y;
      for (@{$building->[@$building - $h--]}) {
         $ty++ and next unless defined $_ && !/[ ]/;
         $T->[$x][$ty++] = $_;
      }
      $x++;
   }
}

# Check if area is free
# arg1: area X position
# arg2: area Y position
# arg3: area height
# arg4: area width
sub check_area_is_free {
   my ($self, $x, $y, $h, $w) = @_;
   die "Wrong number of arguments " unless @_ == 5;

   my $T = get_level_ref();

   while ($h-- > 0) {
      return 0 if grep {!/$qr_free/} @{$T->[$x++]}[$y..$y+$w-1];
   }

   return 1;
}

# (internal, unsafe) Fill specified area with char
sub _fill_area_with_char {
   die "Wrong number of arguments " unless @_ == 5;
   my ($x, $y, $h, $w, $pchar) = @_;

   my $T = get_level_ref();
   while ($h-- > 0) {
      @{$T->[$x++]}[$y..$y+$w-1] = split //, $pchar x $w;
   }
}

# Get free area on the current level
# arg1:      area height
# arg2:      area width
# opt. arg3: area padding
# opt. arg4: padding character
sub get_free_area {
   my ($self, $h, $w, $p, $pchar) = @_;

   # default padding is 0
   $p = 0 unless defined $p;

   die "Invalid height or width" unless defined $h && defined $w;

   my ($H, $W) = get_size();

   die "Level ($W.$H) is too small for area ($w.$h) with padding $p!" if
   ($H < $h + 2 * $p) || ($W < $w + 2 * $p);

   # random X and Y on the level
   my ($rx, $ry);

   #TODO correct ttl value
   my $ttl = 1e3;

   do {
      $rx = $p + int rand($H - 1 - $h - 2 * $p);
      $ry = $p + int rand($W - 1 - $w - 2 * $p);
   } while ($ttl-- > 0 && not check_area_is_free(
         undef, $rx - $p, $ry - $p, $h + 2 * $p, $w + 2 * $p
      )
   );

   die "Unable to get free area" unless $ttl > 0;

   # fill padding area if character specified
   #TODO fill only padding (be careful with S_NONE)
   _fill_area_with_char($rx - $p, $ry - $p, $h + 2 * $p, $w + 2 * $p, $pchar)
   if defined $pchar;

   ($ry, $rx);
}

# Overlay arg1 array over current level on free space
# arg1:      2d array reference
# opt. arg2: padding
# opt. arg3: padding character
sub overlay_anywhere {
   my ($self, $array, $padding, $pchar) = @_;

   die "Not an ARRAY reference at all: $array" unless ref $array eq "ARRAY";
   die "Not an ARRAY reference: $array->[0]" unless ref $array->[0] eq "ARRAY";

   overlay_unsafe(undef, get_free_area(
         undef, scalar @$array, scalar @{$array->[0]}, $padding, $pchar
      ),
      $array
   );
}

# Recreate level and fill it with specified character
# arg1:      Y size of the level
# arg2:      X size of the level
# opt. arg3: a character to fill the level with
sub recreate_level_unsafe {
   my ($self, $y, $x, $char) = @_;
   my $T = get_level_ref();
   $char = ' ' unless defined $char;

   # Feast for garbage collector
   @$T = ();

   # Fill entire level
   @{$T->[$_]} = split //, $char x $x for 0..$y-1;

   update_size();
}

# Rotate specified array
# arg1:      array reference
# opt. arg2: direction ( 0 -- nothing, 1 -- CW, 2 -- 180, 3 -- CCW )
sub array_rotate {
   my ($self, $array, $direction) = @_;

   $direction = int rand 4 unless defined $direction;

   return unless $direction;

   sub _reverse {
      my $ref = $_[0];

      @{$ref->[$_]} = reverse @{$ref->[$_]} for 0..@$ref - 1;
   }

   sub _flip {
      my $ref = $_[0];

      @$ref = reverse @$ref;
   }

   sub _cw {
      my $ref = $_[0];

      my @new;
      for my $line (0..@{$ref->[0]} - 1) {
         @{$new[$line]} = map { $ref->[$_][$line] } 0..@$ref - 1;
      }
      @$ref = @new;
   }

   if ($direction == 1) {      #CW
      _cw($array);
      _reverse($array);
   } elsif ($direction == 2) { # 180 degree rotation
      _flip($array);
      _reverse($array);
   } else {                    # CCW
      _cw($array);
      _flip($array);
   }
}

# Overlay arg1 array over current level on free space with random rotation
# arg1:      array reference
# opt. arg2: hash with args for subroutines:
#  - rotate   => ARRAY (array_rotate)
#  - overlay  => ARRAY (overlay_anywhere)
sub overlay_somehow {
   my ($self, $array, $args) = @_;

   die "Not an ARRAY reference at all: $array" unless ref $array eq "ARRAY";
   die "Not an ARRAY reference: $array->[0]" unless ref $array->[0] eq "ARRAY";

   return array_rotate(undef, $array), overlay_anywhere(undef, $array)
   unless defined $args;

   my (@rotate, @overlay);
   @rotate  = @{$args->{rotate}}  if defined $args->{rotate};
   @overlay = @{$args->{overlay}} if defined $args->{overlay};

   array_rotate(undef, $array, @rotate);
   overlay_anywhere(undef, $array, @overlay);
}

sub generate_blurred_area {
   die "Invalid arguments number" unless @_ == 4;

   my ($self, $level, $char, $factor) = @_;

   die "Level $level does not exist" unless ref $WORLD[$level] eq "ARRAY";

   die "Invalid $factor <> (0..1)" unless $factor >= 0 && $factor <= 1;
   
   my ($h, $w) = get_size(undef, $level);

   my $sy = 0.5 * (1 - $factor) * $h;
   my $sx = 0.5 * (1 - $factor) * $w;

   my $T = get_level_ref();

   # Generate smooth random line y(0) = 0 and y($) = 0
   # arg1: length
   # arg2: start_solid
   # arg3: stop_solid
   # arg4: char
   sub _get_line($$$$) {
      my @L;

      my ($length, $start_solid, $stop_solid, $char) = @_;

      my $curr = 0;

      my $magic_constant = 3;

      # Left side (before solid block)
      do {
         push @L, ($curr >= $magic_constant) ? $char : " ";
         $curr += rand($start_solid) / $start_solid;
      } while (@L < $start_solid);

      # Solid block
      push @L, $char while (@L < $stop_solid);

      $curr = 2 * $magic_constant;

      # Right side (after solid block)
      do {
         push @L, ($curr >= $magic_constant) ? $char : " ";
         $curr -= rand($start_solid) / $start_solid;
      } while (@L < $length);

      @L;
   }

   array_rotate(undef, $T, 1);

   for (my $x = $sx / 2; $x < $w - $sx / 2; $x++) {
      $T->[$x] = [ _get_line($h, $sy, $h - $sy, $char) ];
   }

   array_rotate(undef, $T, 3);

   for (my $y = $sy; $y < $h - $sy; $y++) {
      $T->[$y] = [ _get_line($w, $sx, $w - $sx, $char) ];
   }

   $T;
}

1;
