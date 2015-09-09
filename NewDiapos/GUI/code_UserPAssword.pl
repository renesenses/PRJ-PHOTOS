#!/usr/bin/perl
#
# For simple login dialog
# See example at bottom of file
# 

use strict;
use Wx;

###########################################################
#
# Extend the Frame class to our needs
#
package Wx::Perl::LoginDialog;

use Wx qw( wxTE_PASSWORD wxTE_PROCESS_ENTER );
use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI );

use base qw/Wx::Dialog/;

sub new {
  my $class = shift;
  my $user = shift;
  my $passwd = shift;
 
  my $self = $class->SUPER::new(@_);
  $self->{user_out} = $user;
  $self->{passwd_out} = $passwd;

  $self->{UserLabel} = Wx::StaticText->new(
   $self,    # parent
   -1,        # id
   "User:",   # label
   [10, 30]   # position
  );
  $self->{PasswdLabel} = Wx::StaticText->new(
    $self,     # parent
    -1,         # id
    "Password:",# label
    [10, 50]    # position
  );
 
  $self->{User} = Wx::TextCtrl->new(
    $self,
    -1,
    ${$self->{user_out}} || "",
    [70,30],
    [70,20],
    wxTE_PROCESS_ENTER,
  );

  $self->{Passwd} = Wx::TextCtrl->new(
    $self,
    2,
    ${$self->{passwd_out}} || "",
    [70,50],
    [70,20],
    wxTE_PASSWORD | wxTE_PROCESS_ENTER,
  );

  $self->{Login} = Wx::Button->new(
    $self,
    1,
    "Login",
    [20,90],
  );

  $self->{Cancel} = Wx::Button->new(
    $self,
    2,
    "Cancel",
    [90,90],
  );

  EVT_UPDATE_UI(
    $self,
    -1,
    sub {
      $self->{Passwd}->SetFocus if $$user;
      EVT_UPDATE_UI($self, -1, undef);
    }
  );
 
  EVT_BUTTON(
    $self,     # Object to bind to
    1,         # ButtonID
    \&Login
  );

  EVT_BUTTON(
    $self,     # Object to bind to
    2,         # ButtonID
    \&CancelLogin # Subroutine to execute
  );

  EVT_TEXT_ENTER(
    $self,
    -1,
    \&Login
  );

  $self->{Passwd}->SetFocus if $$user;
  return $self;
}

sub Login { 
  my $self = shift;
  ${$self->{user_out}} = $self->{User}->GetValue;
  ${$self->{passwd_out}} = $self->{Passwd}->GetValue;
  $self->EndModal(1);
}

sub CancelLogin { 
  my $self = shift;
  $self->EndModal(0);
}

###########################################################
#
package Wx::Perl::LoginWindow;

use base qw(Wx::App);   # Inherit from Wx::App
use Wx qw(wxCAPTION wxSYSTEM_MENU);
our ($user, $passwd, $ok);

sub BindVars {
  my $self = shift;
  ($user, $passwd, $ok) = @_;
  $self;
}

sub OnInit {
  my $self = shift;
  $$ok = Wx::Perl::LoginDialog->new(
    $user,
    $passwd,
    undef,         # Parent window
    -1,            # Window id
    'Login',       # Title
    [200,200],     # position X, Y
    [200,150],     # size X, Y
    wxCAPTION | wxSYSTEM_MENU
  )->ShowModal;
  0;
}

package LoginDialog;

sub get_login {
  shift;
  my $ok;
  my $app = eval { Wx::Perl::LoginWindow->BindVars(@_, \$ok)->new };
  die $@ unless $@ =~ "OnInit must return a true return value";
  $ok;
}

1;
###########################################################
#
# The main program
#
package main;
unless( caller ){

    if( @ARGV ) {
        LoginDialog->get_login(\my ($user, $passwd));
        die "USER $user\n\nPASS $passwd\n\n";
    } else { # Use defaults if available:

        my ($user, $passwd) = @ARGV;
        # Default either one if desired
        $user = 'username';

        unless ($user and $passwd) {
            # require LoginDialog;
            LoginDialog->get_login(\($user, $passwd));
        }
    }
}
