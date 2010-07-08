package Dist::Zilla::PluginBundle::II;
use II::Defaults::Class;
# ABSTRACT: basic pluginbundle for internal use

use Dist::Zilla;
with 'Dist::Zilla::Role::PluginBundle::Easy';

# XXX: to make strictconstructor happy for now
has package => (
    is  => 'ro',
    isa => 'Str',
);

has plugin_options => (
    is       => 'ro',
    isa      => 'HashRef[HashRef[Str]]',
    init_arg => undef,
    lazy     => 1,
    default  => sub {
        my $self = shift;
        my %opts = (
            'NextRelease'        => { format => '%-5v %{yyyy-MM-dd}d' },
            'Git::Check'         => { allow_dirty => '' },
            'Git::Tag'           => { tag_format => '%v', tag_message => '' },
            'BumpVersionFromGit' => {
                version_regexp => '^(\d+\.\d+)$',
                first_version  => '0.01',
            }
        );

        for my $option (keys %{ $self->payload }) {
            next unless $option =~ /^([A-Z][^_]*)_(.+)$/;
            my ($plugin, $plugin_option) = ($1, $2);
            $opts{$plugin} ||= {};
            $opts{$plugin}->{$plugin_option} = $self->payload->{$option};
        }

        return \%opts;
    },
);

sub configure {
    my $self = shift;
    my @plugins = (
        # @Basic
        'GatherDir',
        'PruneCruft',
        'ManifestSkip',
        'MetaYAML',
        'License',
        'ExtraTests',
        'ExecDir',
        'ShareDir',
        'MakeMaker',
        'Manifest',

        # other core plugins
        'MetaConfig',
        'MetaJSON',
        'NextRelease',
        'PkgVersion',

        # external plugins
        'CheckChangesHasContent',
        'NoTabsTests',
        'EOLTests',
        'CompileTests',
        'Git::Check',
        'Git::Tag',
        'BumpVersionFromGit',
    );
    $self->add_plugins(
        map { [ $_ => ($self->plugin_options->{$_} || {}) ] } @plugins
    );
}

__PACKAGE__->meta->make_immutable;

1;
