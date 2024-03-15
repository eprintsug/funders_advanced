# Populate the new funders field with any values from the old
$c->add_dataset_trigger( 'eprint', EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub
{
	my( %args ) = @_;
	my( $repo, $eprint, $changed ) = @args{qw( repository dataobj changed )};

    # trigger is global - check that current repository actually has funders_advanced enabled
	return unless $eprint->dataset->has_field( "funders_advanced" );
	
	# if this is an existing record, or a new record that has been imported, initialise the 'funders_advanced' field
	if( !$changed->{funders_advanced_name} && !$eprint->is_set( "funders_advanced" ) && $eprint->is_set( "funders" ) )
	{
        my @new_funders = ();
        foreach my $funder ( @{$eprint->value( "funders" )} )
        {
            push @new_funders, { name => $funder };
        }
        $eprint->set_value( "funders_advanced", \@new_funders );
	}
}, priority => 100 );
