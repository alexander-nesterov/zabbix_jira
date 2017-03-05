#!/usr/bin/perl

use strict;
use warnings;
use JSON qw(encode_json decode_json);
use REST::Client;
use MIME::Base64;
use Getopt::Long;
use Term::ANSIColor;
use utf8;
use Data::Dumper; #for debug

#Documentation:
#https://developer.atlassian.com/jiradev/jira-apis/jira-rest-apis/jira-rest-api-tutorials/jira-rest-api-example-query-issues

#Using:
#./delete_tickets_regex.pl --k 'ZBX' --f 'summary' --r 'ClientCards' --a 'show' --m 2 --u 'zabbix-jira' --p '^7Nm$3%7GtR%6'
#k => project key
#f => search field
#r => regex
#a => action (show, delete)
#m => max results
#u => user
#p => password

my $PROJECT_KEY;
my $FIELD;
my $RGX;
my $ACTION;
my $MAX_RESULTS;
my $USER;
my $PASSWORD;
my $API_URL = 'http://jira.nsk.cwc.ru:8080/rest/api/2/';

my %issue_field = (
		    key => 'key',
		    creator => '{fields}{creator}{name}',
		    assignee => '{fields}{assignee}{name}',
		    summary => '{fields}{summary}',
		    description => '{fields}{description}'
);

&main();

sub main
{
    system('clear');

    &parse();
    &parse_issue();
}

sub parse
{
    GetOptions ('k=s' => \$PROJECT_KEY,
		'f=s' => \$FIELD,
		'r=s' => \$RGX,
		'a=s' => \$ACTION,
		'm=s' => \$MAX_RESULTS,
		'u=s' => \$USER,
		'p=s' => \$PASSWORD);
}

sub set_headers
{
    my $headers;

    $headers = {'Content-Type' => 'application/json', 'Authorization' => 'Basic ' . encode_base64($USER . ':' . $PASSWORD)};

    return $headers;
}

sub send_data
{
    my $client = REST::Client->new();

    my $headers = &set_headers();

    $client->GET($API_URL . "search?jql=project=$PROJECT_KEY&maxResults=$MAX_RESULTS", $headers);

    my $responseCode = $client->responseCode();

    if ($responseCode != 200)
    {
	my $errmsg = $client->responseContent();

	print("Error: $errmsg\r\n");

	exit 1;
    }

    return $client->responseContent();
}

sub parse_issue
{
    my $data = decode_json(&send_data());

    #print Dumper($data);
    binmode STDOUT, ":utf8";

    my @issue = @{$data->{'issues'}};

    foreach my $a (@issue)
    {
	#Key of task
        my $key = $a->{$issue_field{'key'}};
	&println("Key => $key", 'bold green');

	#my $key1 = $issue_field{'key'};
        #print($key1);

        #Идем по хэшу и сравниваем ключи с $FIELD
        #Если ключ равен $FIELD то результат передаем в функцию println_regex
        while (my ($k, $v) = each %issue_field)
        {
          if ($FIELD eq $k)
          {
            #print "$v\r\n";
          }
        }

	#Creator of task
	my $creator = $a->{'fields'}{'creator'}{'name'};
	&println("\tCreator => $creator");

	#Assignee
	my $assignee = $a->{'fields'}{'assignee'}{'name'};
	&println("\tAssignee => $assignee");

	#Summary
	my $summary = $a->{'fields'}{'summary'};
	&println("\tSummary => $summary");

	#Description
	my $description = $a->{'fields'}{'description'};
	&println("\tDescription => $description");
    }
}

sub println_regex
{

}

sub println
{
    my ($text, $color) = @_;

    print color('reset');

    if (defined $color)
    {
	print color($color);
    }

    print("$text\r\n");
}
