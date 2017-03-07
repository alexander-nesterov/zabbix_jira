#!/usr/bin/perl

use strict;
use warnings;
use JSON;
use REST::Client;
use MIME::Base64;
use Data::Dumper;
use Getopt::Long;
use Encode;

#for test
#perl create_ticket.pl --s 'Error' --d 'Description alert' --k 'ZBX' --t 'Task' --u 'zabbix-jira' --p 'your_password'
#s => summary
#d => description
#k => project key
#t => project type
#u => user
#p => password

#============================================================================
#Global variables
#============================================================================
my $USER;
my $PASSWORD;
my $API_URL = 'http://jira:8080/rest/api/2/issue/';
my $PROJECT_KEY;
my $PROJECT_TYPE;
my $SUMMARY;
my $DESCRIPTION;

#============================================================================
#Constants
#============================================================================
use constant DEBUG 	=> 0;
use constant FILE_LOG	=> '/var/log/zabbix/jira.log'; 

#============================================================================
create_task();

#============================================================================
sub create_task
{
    system('clear');

    GetOptions ('s=s' => \$SUMMARY,
    'd=s' => \$DESCRIPTION, 
    'k=s' => \$PROJECT_KEY,
    't=s' => \$PROJECT_TYPE,
    'u=s' => \$USER,
    'p=s' => \$PASSWORD);

    $SUMMARY = decode('UTF-8', $SUMMARY);
    $DESCRIPTION = decode('UTF-8', $DESCRIPTION);

    my $HEADERS = {'Content-Type' => 'application/json', 'Authorization' => 'Basic ' . encode_base64($USER . ':' . $PASSWORD)};

    my $data = fill_json();

    my $client = REST::Client->new();

    $client->POST($API_URL, ($data, $HEADERS));

    my $responseCode = $client->responseCode();

    if ($responseCode != 201)
    {
	print "Error, response status: $client->responseCode()\n";

	write_log_to_file(Dumper($client->responseContent())) if DEBUG;

	exit 0;
    }

    print "Ticket is created\n";
}

#============================================================================
sub write_log_to_file
{
    my $log = shift;

    open(my $fh, '>>', FILE_LOG);

    print $fh "$log\n";

    close $fh;
}

#============================================================================
sub fill_json
{
    my %json;

    $json{'fields'}{'project'}{'key'} = $PROJECT_KEY;
    $json{'fields'}{'summary'} = $SUMMARY;
    $json{'fields'}{'description'} = $DESCRIPTION;
    $json{'fields'}{'issuetype'}{'name'} = $PROJECT_TYPE;
    $json{'fields'}{'priority'}{'id'} = '2';

    #Priority id
    #1 - Blocker
    #2 - Critical
    #3 - General
    #4 - Minor
    #5 - Trivial

    return encode_json(\%json);
}


