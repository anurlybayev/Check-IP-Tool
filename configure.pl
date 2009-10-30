#!/usr/bin/perl

use strict;
use warnings;
use DB_File;
use Crypt::Lite;
use vars qw($VERSION);
$VERSION = '0.1';

my $config = "config.db";
my $crypt = Crypt::Lite->new( debug => 0, encoding => 'hex8' );
my %db;

print "Please enter your GMail id:\n";
my $gmail = <STDIN>;
chomp $gmail;
if ( $gmail =~ /([\w\.]+\@gmail\.com)/ ) {
	$gmail = $crypt->encrypt( $1, $config );
}
else {
	die "$gmail is not valid GMail id\n";
}
print "GMail password:\n";
my $passwd = <STDIN>;
chomp $passwd;
$passwd = $crypt->encrypt( $passwd, $config );
print "e-mail address where you want message delivered:\n";
my $dest = <STDIN>;
chomp $dest;

if ( $dest =~ /([\w\.]+\@\w+\.\w{2,3})/ ) {
	$dest = $crypt->encrypt( $1, $config );
}
else {
	die "$dest is not valid e-mail address\n";
}

tie( %db, 'DB_File', $config ) or die "Can't open DB_File $config : $!\n";
%db              = ();
$db{username}    = $gmail;
$db{password}    = $passwd;
$db{destination} = $dest;
untie %db;
