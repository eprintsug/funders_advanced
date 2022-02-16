# Missing IDs Report
$c->{plugins}{"Screen::Report::FundersMissingIDs"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::FundersMissingIDs"}{params}{custom} = 1;
$c->{funders_missing_ids}->{sortfields} = $c->{eprint_report}->{sortfields};
$c->{funders_missing_ids}->{exportfields} = $c->{eprint_report}->{exportfields};
$c->{funders_missing_ids}->{exportfield_defaults} = $c->{eprint_report}->{exportfield_defaults};
$c->{funders_missing_ids}->{export_plugins} = $c->{eprint_report}->{export_plugins};
$c->{search}->{funders_missing_ids} = $c->{search}->{advanced};
