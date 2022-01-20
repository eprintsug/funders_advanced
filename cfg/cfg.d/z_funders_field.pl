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
