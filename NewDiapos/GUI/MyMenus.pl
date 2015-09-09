#!/usr/bin/perl -w

use strict;
use Wx;

package WxPerlComExample;

use base qw(Wx::App);

sub OnInit {
    my $self  = shift;
    my $frame = WxPerlComExampleFrame->new(undef, -1, "WxPerl Example");

    $frame->Show(1);
    $self->SetTopWindow($frame);

    return 1;
}

package WxPerlComExampleFrame;

use base qw(Wx::Frame);

use Wx qw( 
    wxDefaultPosition wxDefaultSize wxDefaultPosition wxDefaultSize wxID_EXIT
);

use Wx::Event qw(EVT_MENU);

our @id = (0 .. 100); # IDs array

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    ### CODE GOES HERE ###

    return $self;
}

use Wx qw(wxOK wxCENTRE);

# The following subroutine will be called when you click in the normal item

sub ShowDialog {
  my($self, $event) = @_;
  Wx::MessageBox( "This is a dialog", 
                  "Wx::MessageBox example", 
                   wxOK|wxCENTRE, 
                   $self
               );
}

# Create menus
# Action's sub menu
my $submenu = Wx::Menu->new();
$submenu->Append($id[2], "New normal item");
$submenu->Append($id[3], "Delete normal item");
$submenu->AppendSeparator();
$submenu->Append($id[4], "New check item");
$submenu->Append($id[5], "Delete check item");
$submenu->AppendSeparator();
$submenu->Append($id[6], "New radio item");
$submenu->Append($id[7], "Delete radio item");

# Disable items for this submenu
for(2..7) {
    $submenu->Enable($id[$_], 0);
}

# Actions menu
my $actionmenu = Wx::Menu->new();
$actionmenu->Append($id[0], "Create Menu"); # Create new menu
$actionmenu->Append($id[1], "Delete Menu"); # Delete New Menu
$actionmenu->AppendSeparator();
$actionmenu->AppendSubMenu($id[100], "New Item", $submenu); # Create item submenu
$actionmenu->AppendSeparator();
$actionmenu->Append(wxID_EXIT, "Exit\tCtrl+X"); # Exit

# At first, disable the Delete Menu option
$actionmenu->Enable($id[1], 0);

# Create menu bar
$self->{MENU} = Wx::MenuBar->new();
$self->{MENU}->Append($actionmenu, "Actions");

# Attach menubar to the window
$self->SetMenuBar($self->{MENU});
$self->SetAutoLayout(1);

# Handle events
EVT_MENU($self, $id[0], \&MakeActionMenu);
EVT_MENU($self, $id[1], \&MakeActionMenu);
EVT_MENU($self, $id[2], \&MakeActionNormal);
EVT_MENU($self, $id[3], \&MakeActionNormal);
EVT_MENU($self, $id[4], \&MakeActionCheck);
EVT_MENU($self, $id[5], \&MakeActionCheck);
EVT_MENU($self, $id[6], \&MakeActionRadio);
EVT_MENU($self, $id[7], \&MakeActionRadio);

EVT_MENU($self, wxID_EXIT, sub {$_[0]->Close(1)});

# Subroutine that handles menu creation/erasure
sub MakeActionMenu {
    my($self, $event) = @_;

    # Get Actions menu
    my $actionmenu    = $self->{MENU}->GetMenu(0);

    # Now check if we have to create or delete the New Menu
    if ($self->{MENU}->GetMenuCount() == 1) {
        # New Menu doesn't exist

        # Create menu
        my $newmenu = Wx::Menu->new();
        $self->{MENU}->Append($newmenu, "New Menu");       

        # Disable and Enable options
        $actionmenu->Enable($id[0], 0); # New menu
        $actionmenu->Enable($id[1], 1); # Delete menu
        $actionmenu->Enable($id[2], 1); # New normal item
        $actionmenu->Enable($id[3], 0); # Delete normal item
        $actionmenu->Enable($id[4], 1); # New check item
        $actionmenu->Enable($id[5], 0); # Delete check item
        $actionmenu->Enable($id[6], 1); # New radio item
        $actionmenu->Enable($id[7], 0); # Delete radio item
    } else {
        # New Menu exists

        # Remove menu
       $self->{MENU}->Remove(1);

        # Enable and disable options
        $actionmenu->Enable($id[0], 1);

        for(1..7) {
               $actionmenu->Enable($id[$_], 0);
        }
    }

    return 1;
}

# Subroutine that handles normal item creation/erasure
sub MakeActionNormal {
    my($self, $event) = @_;
    # Check if New Menu exists
    if($self->{MENU}->GetMenuCount() == 2) {
        # New menu exists

        # Get Action menu
        my $actionmenu = $self->{MENU}->GetMenu(0);
        my $newmenu    = $self->{MENU}->GetMenu(1);

        # Check if we have to create or delete a menu item
        if($actionmenu->IsEnabled($id[2])) {
            # Create normal menu item
            $newmenu->Append($id[50], "Normal item");           

            # Disable and Enable options
            $actionmenu->Enable($id[2], 0);
            $actionmenu->Enable($id[3], 1);
        } else {
            # Delete menu item
               $newmenu->Delete($id[50]);

            # Enable and disable options
            $actionmenu->Enable($id[2], 1);
            $actionmenu->Enable($id[3], 0);
        }
    }

    return 1;
}

# Subroutine that handles check item creation/erasure
sub MakeActionCheck {
    my($self, $event) = @_;

    # Check if New Menu exists
    if($self->{MENU}->GetMenuCount() == 2) {
        # New menu exists

        # Get Action menu
        my $actionmenu = $self->{MENU}->GetMenu(0);
        my $newmenu    = $self->{MENU}->GetMenu(1);

        # Check if we have to create or delete a menu item
        if($actionmenu->IsEnabled($id[4])) {
            # Create check item
               $newmenu->AppendCheckItem($id[51], "Check item");

           # Disable and Enable options
           $actionmenu->Enable($id[4], 0);
           $actionmenu->Enable($id[5], 1);
        } else {
           # Delete menu item
           $newmenu->Delete($id[51]);

              # Enable and disable options
              $actionmenu->Enable($id[4], 1);
              $actionmenu->Enable($id[5], 0);
        }
    }

    return 1;
}

# Subroutine that handles radio item creation/erasure

sub MakeActionRadio {
    my($self, $event) = @_;

    # Check if New Menu exists
    if($self->{MENU}->GetMenuCount() == 2) {
        # New menu exists

        # Get Action menu
        my $actionmenu = $self->{MENU}->GetMenu(0);
        my $newmenu    = $self->{MENU}->GetMenu(1);

        # Check if we have to create or delete a menu item
        if ($actionmenu->IsEnabled($id[6])) {
               # Create radio item
              $newmenu->AppendRadioItem($id[52], "Radio item");

              # Disable and Enable options
              $actionmenu->Enable($id[6], 0);
              $actionmenu->Enable($id[7], 1);
        } else {
              # Delete menu item
              $newmenu->Delete($id[52]);

              # Enable and disable options
              $actionmenu->Enable($id[6], 1);
              $actionmenu->Enable($id[7], 0);
        }
    }

    return 1;
}

package main;

my($app) = WxPerlComExample->new();

$app->MainLoop();

# Create menus
my $firstmenu = Wx::Menu->new();
$firstmenu->Append($id[0], "Normal Item");
$firstmenu->AppendCheckItem($id[1], "Check Item");
$firstmenu->AppendSeparator();
$firstmenu->AppendRadioItem($id[2], "Radio Item");

my $secmenu   = Wx::Menu->new();
$secmenu->Append(wxID_EXIT, "Exit\tCtrl+X");

# Create menu bar
my $menubar   = Wx::MenuBar->new();
$menubar->Append($firstmenu, "First Menu");
$menubar->Append($secmenu, "Exit Menu");

# Attach menubar to the window
$self->SetMenuBar($menubar);
$self->SetAutoLayout(1);

# Handle events only for Exit and Normal item
EVT_MENU( $self, $id[0], \&ShowDialog );
EVT_MENU( $self, wxID_EXIT, sub {$_[0]->Close(1)} );
Insert the following code into the base code at the line ### PUT SUBROUTINES HERE ###.

