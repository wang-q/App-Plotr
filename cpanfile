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

requires 'AlignDB::IntSpan', '1.1.0';
requires 'App::RL',          '0.3.0';
requires 'App::Fasops',      '0.5.16';
requires 'perl',             '5.018001';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

