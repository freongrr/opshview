package OpsView::Commands;
use strict;

# TODO : perldoc?

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

sub host {
    my ($class, $connector, $hostname) = @_;
    return $connector->request('status/host')->{'list'};
}

sub service {
    my ($class, $connector, $hostname) = @_;
    if (defined($hostname)) {
        return $connector->request('status/service?host='.$hostname)->{'list'};
    } else {
        return $connector->request('status/service')->{'list'};
    }
}

1;
