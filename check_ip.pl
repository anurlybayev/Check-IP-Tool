#!/usr/bin/perl

use strict;
use warnings;

use Email::Send;
use Email::Send::Gmail;
use Email::Simple::Creator;

use constant IP_ARCHIVE_FILE => '/path/to/your/ip/archive/file';
use constant GMAIL_USER_ID   => 'source@gmail.com';
use constant GMAIL_PASSWD    => 'XXXXXX';
use constant DEST_EMAIL      => 'destination@gmail.com';
use constant SUBJECT         => 'Your IP-address has changed';

my $ip_archive = IP_ARCHIVE_FILE;
my $ip         = `curl -s http://checkip.dyndns.org`;
$ip =~ s/.*?(\d+\.\d+\.\d+\.\d+).*/$1/s;

open( IP, "<", $ip_archive ) or die "Cannot open $ip_archive: $!";
my $ip_last_check = <IP>;
close IP;

if ( $ip ne $ip_last_check ) {
	open( IP, ">", $ip_archive ) or die "Cannot open $ip_archive: $!";
	print IP $ip;
	close(IP);

	my $email = Email::Simple->create(
		header => [
			From    => GMAIL_USER_ID,
			To      => DEST_EMAIL,
			Subject => SUBJECT,
		],
		body => "Your IP-address has changed to $ip",
	);

	my $sender = Email::Send->new(
		{
			mailer      => 'Gmail',
			mailer_args => [
				username => GMAIL_USER_ID,
				password => GMAIL_PASSWD,
			]
		}
	);
	eval { $sender->send($email) };
	die "Error sending email: $@" if $@;
}

exit;
