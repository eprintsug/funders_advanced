package EPrints::FundersAdvanced::Utils;

use strict;

sub crossref_query
{
	my( $repo, $name ) = @_;

    # build the request
    my $url = "https://api.crossref.org/funders";

    # add the name to the query
    $name =~ tr/ /+/;
    $url .= "?query=$name";

    my $ua = LWP::UserAgent->new;

    # User-Agent header for politeness
    my $ua_header = $repo->phrase( "archive_name" ) . " ( " . $repo->config( "host" ) . "; mailto:" . $repo->config( "adminemail" ) . ")";

    my $headers = HTTP::Headers->new(
        'Accept' => 'application/json',
        'User-Agent' => $ua_header,
    );

    my $req =  HTTP::Request->new(
        GET => $url,
        $headers,
    );

    my $res = $ua->request( $req );
    if( $res->is_success )
    {
        my $json = JSON->new->utf8;
        my $content = $json->decode( $res->content );

        return $content;
    }
    else
    {
        $repo->log( "CrossRef lookup failed: " . $res->code . ", " . $res->content );
        return 0;
    }    
}

1;

