#!/usr/bin/perl
use strict;

use Getopt::Long;
use Pod::Usage;

require OpsView::Connector;
require OpsView::Commands;
require OpsView::Printer;

use constant COMMANDS => qw(token get hostgroup viewport host service);

use constant DEFAULT_URL => "http://opsview";

eval {
    # Provide some introspection to the .sh
    if ($ARGV[0] eq 'commands') {
        print join("\n", COMMANDS)."\n";
    } else {
        main();
    }
};
if ($@) {
  print STDERR "ERROR: ".$@."\n";
  exit 1;
}

sub main {
    my $username;
    my $password;
    my $token;
    my $destination = DEFAULT_URL;
    my $help = 0;
    my $man = 0;

    if (!GetOptions(
        'username|u=s'      => \$username,
        'password|p=s'      => \$password,
        'token|t=s'         => \$token,
        'destination|d=s'   => \$destination,
        'help|?'            => \$help,
        'man'               => \$man)) {
        pod2usage(2);
    } elsif ($help) {
        pod2usage(1);
    } elsif ($man) {
        pod2usage(-exitstatus => 0, -verbose => 2);
    } elsif (!defined($username)) {
        pod2usage("Missing username");
    }

    my $connector = new OpsView::Connector($destination);

    if ($password) {
        # Username and password given on the command line
        $connector->login($username, $password);
    } elsif ($token) {
        # Attempt to resume the session from the token
        $connector->resumeSession($username, $token);
    } else {
        pod2usage("Missing password or token");
    }

    # Execute the command passed in argument
    my ($command, @arguments) = @ARGV;

    # TODO : break that out somehow
    if ($command eq 'token') {
        print $connector->token."\n";
    } elsif ($command eq 'get') {
        my $path = $arguments[0];
        print "GET $path\n";
        my $response = $connector->request($path);
        OpsView::Printer->prettyPrint($response);
    } elsif ($command eq 'viewport') {
        my ($viewName) = @arguments;
        if (defined($viewName)) {
            my $view = OpsView::Commands->viewport($connector, $viewName);
            OpsView::Printer->printView($view);
        } else {
            my $views = OpsView::Commands->viewport($connector);
            OpsView::Printer->printViews($views);
        }
    } elsif ($command eq 'hostgroup') {
        my ($groupId) = @arguments;
        my $groups = OpsView::Commands->hostgroup($connector, $groupId);
        OpsView::Printer->printHostGroups($groups, $groupId);
    } elsif ($command eq 'host') {
        my $hosts = OpsView::Commands->host($connector);
        OpsView::Printer->printHosts($hosts);
    } elsif ($command eq 'service') {
        my ($host) = @arguments;
        my $hosts = OpsView::Commands->service($connector, $host);
        OpsView::Printer->printServices($hosts);
    } elsif ($command) {
        pod2usage("Unexpected command: $command");
    } else {
        pod2usage("Missing command");
    }

    exit 0;
}

__END__

=head1 NAME

Perl connector for OpsView

=head1 SYNOPSIS

perl OpsView.pl
[-u|--username I<username>]
[-p|--password I<password>]
[-d|--destination I<url>]
[-t|--token I<token>]
[--help]
I<command> [I<argument> ...]

=head1 OPTIONS

=over 8

=item B<-u> I<username>, B<--username> I<username>

The user name to log in with.

=item B<-p> I<password>, B<--password> I<password>

The password to log in with.

=item B<-t> I<token>, B<--token> I<token>

When resuming a connection, the session token.

=item B<-d> I<url>, B<--destination> I<url>

The URL of the OpsView web interface.

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Print the manual page and exits.

=back

=head1 COMMANDS

=over 8

=item B<token>

Print out the identifier of the session.

=item B<get> I<path>

Call the RESTful interface (at http//<opsview>/rest/<path>) and print out the result.

=item B<hostgroup> [I<groupid>]

Print the host group hierarchy. If a group id is given, the tree starts from this node.

=item B<viewport> [I<viewname>]

Print the views. If a view name is given, the hosts and services it contains are printed out.

=back

TODO - more commands

=cut
