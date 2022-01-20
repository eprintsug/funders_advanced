# If the rioxx2 package is installed, configure it to look in the
# new 'funders_advanced' field to find values
for( @{$c->{fields}->{eprint}} )
{
	$_->{rioxx2_value} = "rioxx2_value_funders_advanced" if $_->{name} eq "rioxx2_project";	
}

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
