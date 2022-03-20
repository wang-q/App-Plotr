requires 'App::Cmd', '0.330';
requires 'IO::Zlib';
requires 'IPC::Cmd';
requires 'List::Util';
requires 'List::MoreUtils', '0.428';
requires 'Path::Tiny',      '0.076';
requires 'Statistics::R',   '0.34';
requires 'Template',        '2.26';
requires 'Tie::IxHash',     '1.23';
requires 'YAML::Syck',      '1.29';

requires 'Excel::Writer::XLSX',     '1.03';
requires 'Spreadsheet::ParseExcel', '0.65';
requires 'Spreadsheet::XLSX',       '0.15';
requires 'Text::CSV_XS',            '1.41';

requires 'AlignDB::IntSpan', '1.1.0';
requires 'perl',             '5.018001';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
