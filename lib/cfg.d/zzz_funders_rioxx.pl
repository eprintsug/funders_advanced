# If the rioxx2 package is installed, configure it to look in the
# new 'funders_advanced' field to find values
for( @{$c->{fields}->{eprint}} )
{
    # update the value and validate functions for the project field
	$_->{rioxx2_value} = "rioxx2_value_funders_advanced" if $_->{name} eq "rioxx2_project";	
	$_->{rioxx2_validate} = "rioxx2_validate_funders_advanced" if $_->{name} eq "rioxx2_project";

    # and update the lookup for the manual override field
    $_->{input_lookup_url} = "/cgi/users/lookup/funders_advanced_rioxx" if $_->{name} eq "rioxx2_project_input";
}

# Update value function to get values from the new funders field
$c->{rioxx2_value_funders_advanced} = sub {
	my ( $eprint ) = @_;

    return unless $eprint->is_set( "funders_advanced" ) && $eprint->is_set( "projects" );

    # attempt to give every project a funder (and vice versa)
    my @p = @{ $eprint->value( "projects" ) };
    my @f = @{ $eprint->value( "funders_advanced" ) };

    while( scalar @p < scalar @f )
    {
        # fewer projects than funders - top up project list by repeating last element
        push @p, $p[$#p];
    }

    my @projects;
    for( my $i = 0; $i < scalar @p; $i++ )
    {
        push @projects, {
            project => $p[$i],
            # if fewer funders than projects, use the last funder
            funder_name => ( $i > $#f ? $f[$#f]->{name} : $f[$i]->{name} ),
            funder_id => ( $i > $#f ? $f[$#f]->{id} : $f[$i]->{id} ),
        };
    }
    return \@projects;
};

# Relax the validate function to not check things against a list, 
# now we can be more confident we have a valid name/id pair from Crossref
# (we can't validate against Crossref as this would involve a lot of requests, 
# e.g when generating the rioxx report )
$c->{rioxx2_validate_funders_advanced} = sub {
    my( $repo, $value, $eprint ) = @_;

    my @problems;
    foreach my $entry ( @$value )
    {
        my $project = $entry->{project};
        my $funder_name = $entry->{funder_name};
        my $funder_id = $entry->{funder_id};
        unless( EPrints::Utils::is_set( $project ) )
        {
            push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_done_part_project" );
        }
        unless( EPrints::Utils::is_set( $funder_name ) || EPrints::Utils::is_set( $funder_id ) )
        {
            push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_done_part_funder" );
        }

        if( $funder_id && !EPrints::RIOXX2::Utils::is_http_or_https_uri( $funder_id ) )
        {
            push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_http_uri" );
        }
    }
    return @problems;
};
