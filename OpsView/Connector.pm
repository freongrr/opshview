package OpsView::Connector;
use strict;

require LWP::UserAgent;

sub new {
  my ($class, $baseUrl) = @_;
  return bless {'baseUrl' => $baseUrl}, $class;
}

sub baseUrl {
  my ($self) = @_;
  return $self->{'baseUrl'};
}

sub userName {
  my ($self) = @_;
  return $self->{'userName'};
}

sub token {
  my ($self) = @_;
  return $self->{'token'};
}

sub resumeSession {
  my ($self, $userName, $token) = @_;

  $self->{'userName'} = $userName;
  $self->{'token'} = $token;
}

sub login {
  my ($self, $userName, $password) = @_;

  my $response = new LWP::UserAgent()->post(
    $self->baseUrl() . '/rest/login',
    Content => { 'username' => $userName,
                 'password' => $password }
  );

  if ($response->is_success && $response->decoded_content =~ /\{"token":"(.+)"\}/o) {
    $self->{'token'} = $1;
    $self->{'userName'} = $userName;
  } else {
    die 'Connection failed: ' . $response->message;
  }
}

sub request {
  my ($self, $url) = @_;

  my $response = new LWP::UserAgent()->get(
      $self->baseUrl() . '/rest/' . $url,
      Content_Type         => 'text/x-data-dumper',
      'X-Opsview-Username' => $self->userName(),
      'X-Opsview-Token'    => $self->token()
  );

  if ($response->is_success) {
     return eval $response->decoded_content;
  } else {
    die 'Request failed: ' . $response->message;
  }
}

1;

