package EPrints::Plugin::Screen::Report::FundersMissingIDs;

use EPrints::Plugin::Screen::Report;
our @ISA = ( 'EPrints::Plugin::Screen::Report' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new( %params );

    $self->{datasetid} = 'eprint';
    $self->{report} = 'funders_missing_ids';
    $self->{searchdatasetid} = 'archive';
    $self->{show_compliance} = 0;

    $self->{labels} = {
        outputs => "eprints"
    };

    $self->{sconf} = 'funders_missing_ids';
    $self->{export_conf} = 'funders_missing_ids';
    $self->{sort_conf} = 'funders_missing_ids';
    $self->{group_conf} = 'funders_missing_ids';

    return $self;
}

sub items
{
    my( $self ) = @_;

    my $list = $self->SUPER::items();

    if( defined $list )
    {
        my @ids = ();

        $list->map(sub{
            my( $session, $dataset, $eprint ) = @_;

            my @problems = $self->validate_dataobj( $eprint );

            if( ( scalar( @problems ) > 0 ) && ( $eprint->is_set( "funders_advanced" ) ) )
            {
                push @ids, $eprint->id;
            }
        });
        
        my $ds = $self->{session}->dataset( $self->{datasetid} );
        my $results = $ds->list( \@ids );
        return $results;

    }
    
    # we can't return an EPrints::List if {dataset} is not defined
    return undef;
}

sub ajax_eprint
{
    my( $self ) = @_;

    my $repo = $self->repository;

    my $json = { data => [] };
    $repo->dataset( "eprint" )
        ->list( [$repo->param( "eprint" )] )
        ->map(sub {
            (undef, undef, my $eprint) = @_;

            return if !defined $eprint; # odd

            my $frag = $eprint->render_citation_link;
            push @{$json->{data}}, {
                datasetid => $eprint->dataset->base_id,
                dataobjid => $eprint->id,
                summary => EPrints::XML::to_string( $frag ),
                problems => [ $self->validate_dataobj( $eprint ) ],
            };
        });
    print $self->to_json( $json );
}

sub validate_dataobj
{
    my( $self, $eprint ) = @_;

    my $repo = $self->{repository};

    my @problems;

    foreach my $funder ( @{$eprint->value( "funders_advanced" )} )
    {
        if( exists $funder->{name} && !exists $funder->{id} )
        {
           push @problems, $repo->phrase( "funders_advanced_missing_id", name => $repo->xml->create_text_node( $funder->{name} ) );           
        }
    }

    # if we have problems, add link to edit the funders_advanced field
    if( scalar @problems > 0 )
    {
        my $frag = $repo->xml->create_document_fragment();

        my $dataset = $eprint->dataset;
        my $field = $dataset->field( "funders_advanced" );
        my $r_name = $field->render_name( $eprint->{session} );
        my $name = $field->get_name;
        my $stage = $self->_get_workflow_stage( $eprint, $name );

        my $url = "?eprintid=".$eprint->get_id."&screen=EPrint::Edit&stage=$stage#$name";
        my $link = $eprint->{session}->render_link( $url );
        $link->setAttribute( title => $self->phrase( "edit_field_link",
            field => $self->{session}->xhtml->to_text_dump( $r_name )
        ) );
        $link->appendChild( $r_name );
        $frag->appendChild( $self->html_phrase( "edit_funders_link", link => $link ) );

        push @problems, $frag;
    }

    return @problems;
}

sub _get_workflow_stage
{
    my( $self, $eprint, $name ) = @_;

    my $staff = $self->_allow_edit_eprint;

    my %opts = (
        item => $eprint,
        session => $self->{session},
        processor => $self->{processor},
        STAFF_ONLY => [$staff ? "TRUE" : "FALSE","BOOLEAN"],
    );
    
    my $workflow = EPrints::Workflow->new(
        $self->{session},
        "default",
        %opts
    );

    return $workflow->{field_stages}->{$name};
}

sub _allow_edit_eprint
{
    my( $self, $eprint, $priv ) = @_;

    return 0 unless defined $eprint;

    return 1 if( $self->{session}->allow_anybody( $priv ) );
    return 0 if( !defined $self->{session}->current_user );
    return $self->{session}->current_user->allow( $priv, $eprint );
}
