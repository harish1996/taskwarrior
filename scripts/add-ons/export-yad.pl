#! /usr/bin/perl
################################################################################
## taskwarrior - a command line task list manager.
##
## Copyright 2006 - 2011, Paul Beckingham, Federico Hernandez.
## All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, write to the
##
##     Free Software Foundation, Inc.,
##     51 Franklin Street, Fifth Floor,
##     Boston, MA
##     02110-1301
##     USA
##
################################################################################

use strict;
use warnings;

# Give a nice error if the (non-standard) JSON module is not installed.
eval "use JSON";
if ($@)
{
  print "Error: You need to install the JSON Perl module.\n";
  exit 1;
}

# Use the taskwarrior 2.0+ export command to filter and return JSON
my $command = join (' ', ("env PATH=$ENV{PATH} task export", @ARGV));
if ($command =~ /No matches/)
{
  printf STDERR $command;
  exit 1;
}

# Generate output.
print "'uuid','status','tags','entry','start','due','recur','end','project',",
      "'priority','fg','bg','description'\n";

for my $task (split /,$/ms, qx{$command})
{
  my $data = from_json ($task);

  print "'$data->{'uuid'}',",
        "'$data->{'status'}',",
        "'", (exists $data->{'tags'} ? join (' ', @{$data->{'tags'}}) : ''), "',",
        "'$data->{'entry'}',",
        "'", ($data->{'start'}    || ''), "',",
        "'", ($data->{'due'}      || ''), "',",
        "'", ($data->{'recur'}    || ''), "',",
        "'", ($data->{'end'}      || ''), "',",
        "'", ($data->{'project'}  || ''), "',",
        "'", ($data->{'priority'} || ''), "',",
        "'", ($data->{'fg'}       || ''), "',",
        "'", ($data->{'bg'}       || ''), "',",
        "'$data->{'description'}'",
        "\n";

  # Note that this format ignores:
  #   wait
  #   until
  #   annotations
  #   mask
  #   imask
}

exit 0;

################################################################################

