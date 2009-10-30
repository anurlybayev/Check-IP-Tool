#!/usr/bin/perl

use strict;
use warnings;

use Email::Send;
use Email::Send::Gmail;
use Email::Simple::Creator;
use DB_File;
use Crypt::Lite;
use vars qw($VERSION);
$VERSION = '0.2'; 

my $email_subject = 'Your IP-address has changed';
my $config        = 'config.db';
my $old_ip        = 'ip.db';
my $new_ip        = `curl -s http://checkip.dyndns.org`;

$new_ip =~ s/.*?(\d+\.\d+\.\d+\.\d+).*/$1/s;

die "You should run configure.pl first\n" unless -e -r $config;

tie( my %old_ip, 'DB_File', $old_ip );
$old_ip = $old_ip{address} || "";
$old_ip{address} = $new_ip;
untie %old_ip;

if ( $new_ip ne $old_ip ) {
	tie( my %config, 'DB_File', $config ) or die "Can't open DB_File $config : $!\n";
	my $crypt = Crypt::Lite->new( debug => 0, encoding => 'hex8' );

	my $email = Email::Simple->create(
		header => [
			From    => $crypt->decrypt( $config{username},    $config ),
			To      => $crypt->decrypt( $config{destination}, $config ),
			Subject => $email_subject,
		],
		body => "Your IP-address has changed to $new_ip",
	);

	my $sender = Email::Send->new(
		{
			mailer      => 'Gmail',
			mailer_args => [
				username => $crypt->decrypt( $config{username}, $config ),
				password => $crypt->decrypt( $config{password}, $config ),
			]
		}
	);
	untie %config;
	eval { $sender->send($email) };
	die "Error sending email: $@" if $@;
}

exit;
