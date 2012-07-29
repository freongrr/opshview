package OpsView::Commands;
use strict;

sub hostgroup {
    my ($class, $connector, $groupId) = @_;

    my $url = 'status/hostgroup';
    if (defined($groupId)) {
        # We need 2 queries to get the parent and its children
        my $groups = $connector->request($url.'?hostgroupid='.$groupId)->{'list'};
        if (defined($groups) && scalar($groups)) {
            my $group = $groups->[0];
            my $children = $connector->request($url.'?parentid='.$groupId)->{'list'};
            return [$group, @$children];
        } else {
            return [];
        }
    } else {
        return $connector->request($url)->{'list'};
    }
}

sub viewport {
    my ($class, $connector, $viewName) = @_;
    if (defined($viewName)) {
        return $connector->request('status/viewport/'.$viewName)->{'list'};
    } else {
        return $connector->request('status/viewport')->{'list'};
    }
}

1;
