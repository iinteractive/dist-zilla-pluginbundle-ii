package Dist::Zilla::PluginBundle::II;
# ABSTRACT: basic pluginbundle for internal use

use Moose;
use Dist::Zilla;
with 'Dist::Zilla::Role::PluginBundle::Easy';

has plugin_options => (
    is       => 'ro',
    isa      => 'HashRef[HashRef[Str]]',
    init_arg => undef,
    lazy     => 1,
    default  => sub {
        my $self = shift;
        my %opts = (
            'Git::Check'       => { allow_dirty => '' },
            'Git::NextVersion' => {
                version_regexp => '^(\d+\.\d+)$',
                first_version  => '0.01',
            },
            'Git::Tag'         => { tag_format => '%v', tag_message => '' },
            'NextRelease'      => { format => '%-5v %{yyyy-MM-dd}d' },
        );

        # TODO document how to use this and why you'd want to
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
        'AutoPrereqs',
        'MetaConfig',
        'MetaJSON',
        'NextRelease',
        'PkgVersion',
        'PodVersion',
        'PodCoverageTests',
        'PodSyntaxTests',

        # external plugins
        'CheckChangesHasContent',
        'NoTabsTests',
        'EOLTests',
        'Test::Compile',
        'Git::Check',
        'Git::Commit',
        'Git::NextVersion',
        'Git::Tag',
    );
    $self->add_plugins(
        map { [ $_ => ($self->plugin_options->{$_} || {}) ] } @plugins
    );
}

__PACKAGE__->meta->make_immutable;
1;
