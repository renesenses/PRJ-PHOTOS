#!/usr/bin/perl -w

# ADD CLOSE EVENT

use strict;
use warnings;

package MyFrame;
use Wx qw( :frame :textctrl :sizer :panel :window :id);
use Wx::Event qw(EVT_CLOSE EVT_BUTTON);
use base qw( Wx::Frame );
sub new {
    my($class, $parent) = @_;
    my $self = $class->SUPER::new(
        undef,
        -1,
        'Example Frame',
        [-1,-1],
        [-1,-1],
        wxDEFAULT_FRAME_STYLE );
    my $topsizer = Wx::BoxSizer->new(wxVERTICAL);
    # create Wx::Panel to use as a parent
    my $panel = Wx::Panel->new(
        $self, -1, [-1,-1], [-1,-1],
        wxTAB_TRAVERSAL|wxBORDER_NONE
    );
    # create a text control with minimal size 100x60
    my $text = Wx::TextCtrl->new(
        $panel, 		#parent
         -1,			#id
         '',			#default value
        [-1,-1],		#text control position
        [100,60],		#text control size
        wxTE_MULTILINE
    );
    $topsizer->Add(
        $text,
        1,           # make vertically stretchable
        wxEXPAND |   # make horizontally stretchable
        wxALL,       #    and make border all around
        10           # set border width to 10
    );
    my $btnok     = Wx::Button->new($panel, wxID_OK, 'OK');
    my $btncancel = Wx::Button->new($panel, wxID_CANCEL, 'Cancel');
    my $buttonsizer = Wx::BoxSizer->new(wxHORIZONTAL);
    $buttonsizer->Add(
        $btnok,
        0,           # make horizontally unstretchable
        wxALL,       # make border all around (implicit top alignment)
        10           # set border width to 10
    );
    $buttonsizer->Add(
        $btncancel,
        0,           # make horizontally unstretchable
        wxALL,       # make border all around (implicit top alignment)
        10           # set border width to 10
    );
    $topsizer->Add(
        $buttonsizer,
        0,             # make vertically unstretchable
        wxALIGN_CENTER # no border and centre horizontally
    );
    $panel->SetSizer( $topsizer );
    my $mainsizer = Wx::BoxSizer->new(wxVERTICAL);
    $mainsizer->Add($panel, 1, wxEXPAND|wxALL, 0);
    # use the sizer for layout and size frame
    # preventing it from being resized to a
    # smaller size;
    $self->SetSizerAndFit($mainsizer );
    
    EVT_BUTTON( $self, $btncancel, \&OnClose ); # GW : close la frame
#    EVT_BUTTON( $panel, $btncancel, \&OnClose ); #GW : close le panel
#    EVT_BUTTON( $panel, $btok, \&OnOk );
    EVT_CLOSE( $self, \&OnClose );
    
    return $self;
}

sub OnClose {
    my( $this, $event ) = @_;

    $this->Destroy;
}

package main;

my $app = Wx::SimpleApp->new;
my $frame = MyFrame->new();
$frame->Show;
$app->MainLoop;
