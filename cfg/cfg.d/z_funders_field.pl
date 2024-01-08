# define an archive name override used during crossref requests
#$c->{funders_advanced}->{archive_name} = "Repository Name Here";

# define the number of characters that need to be input before we go querying the crossref api
$c->{funders_advanced}->{ror_name_threshold} = 2;
$c->{funders_advanced}->{ror_id_threshold} = 8;

$c->add_dataset_field( "eprint",
{
    name => 'funders_advanced',
    type => 'compound',
    fields => [
        { sub_name => "name", type => "text", input_cols => "25" },
        { sub_name => "id", type => "url", input_cols => "25" },
    ],
    multiple => 1,
    input_lookup_url => "/cgi/users/lookup/funders_advanced",
});
