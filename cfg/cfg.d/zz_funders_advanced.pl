# Missing IDs Report
$c->{plugins}{"Screen::Report::FundersMissingIDs"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::FundersMissingIDs"}{params}{custom} = 1;
$c->{funders_missing_ids}->{export_plugins} = $c->{eprint_report}->{export_plugins};
$c->{funders_missing_ids}->{sortfields} = $c->{eprint_report}->{sortfields};

$c->{funders_missing_ids}->{exportfields} = {
    funders_missing_ids => [
        @{$c->{eprint_report}->{exportfields}->{eprint_report_core}},
        "funders_advanced_name",
        "funders_advanced_id",
        "projects",
    ],
};

$c->{funders_missing_ids}->{exportfield_defaults} = [
    @{$c->{eprint_report}->{exportfield_defaults}},
    "funders_advanced_name",
    "funders_advanced_id",
    "projects",
];

$c->{search}->{funders_missing_ids} = {
    search_fields => [
        { meta_fields => [ "funders_advanced_name" ] },
        { meta_fields => [ "funders_advanced_id" ] },
        { meta_fields => [ "projects" ] },
        @{$c->{search}{advanced}{search_fields}},
    ],
    preamble_phrase => "cgi/advsearch:preamble",
    title_phrase => "cgi/advsearch:adv_search",
    citation => "result",
    page_size => 20,
    order_methods => {
        "byyear"     => "-date/creators_name/title",
        "byyearoldest"   => "date/creators_name/title",
        "byname"     => "creators_name/-date/title",
        "bytitle"    => "title/creators_name/-date",
        "bydepositdate"      => "-datestamp/creators_name/title",
        "bydepositdateoldest"    => "datestamp/creators_name/title",
    },
    default_order => "byyear",
    show_zero_results => 1,
};
