#!/usr/bin/perl -w

# REPLACE textCtrl by ListBox

use strict;
use warnings;

package MyYearFrame;
use Wx qw( :frame :textctrl :listbox :sizer :panel :window :id);
use Wx::Event qw(EVT_CLOSE EVT_BUTTON);
use base qw( Wx::Frame );
sub new {
    my($class,$YearFrameName, $refYears) = @_;
    my $self = $class->SUPER::new(
        undef,
        -1,
        "Ces années là",
        [-1,-1],
        [-1,-1],
        wxDEFAULT_FRAME_STYLE );
    my $topsizer = Wx::BoxSizer->new(wxVERTICAL);
    # create Wx::Panel to use as a parent
    
# Usage: Wx::Panel
#	parent, \
#	id = wxID_ANY, \
#	pos = wxDefaultPosition, \
#	size = wxDefaultSize, \
#	style = 0, \
#	name = wxListBoxNameStr)
    
    my $panel = Wx::Panel->new(
        $self, -1, [-1,-1], [-1,-1],
        wxTAB_TRAVERSAL|wxBORDER_NONE
    );
    # create a text control with minimal size 100x60
    
# Usage: Wx::ListBox::newFull(CLASS, \
#	parent, \
#	id = wxID_ANY, \
#	pos = wxDefaultPosition, \
#	size = wxDefaultSize, \
#	choices = 0, \
#	style = 0, \
#	validator = (wxValidator*)&wxDefaultValidator, \
#	name = wxListBoxNameStr)
    
    my $box = Wx::ListBox->new(
        $panel, 			#parent
        -1,					#id
        [-1,-1],			#pos
        [-1,-1],			#size
#        0,					#nb of items
        ["2000","2001"],			#items list ref to yearsRange
        ,					#validator         
#       @yearsRange,		#items list instead of pred line 
        wxLB_SINGLE|wxLB_HSCROLL|wxLB_NEEDED_SB|wxLB_SORT
    );
    $topsizer->Add(
        $box,
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

my @yearsRange;
my $yearStart = 1963;
my @time = localtime(time);
my $yearEnd = $time[5]+1900;

for my $year ( $yearStart .. $yearEnd ) {
	push @yearsRange, "$year";
}

my $app = Wx::SimpleApp->new;
my $frame = MyYearFrame->new();
# my $frame = MyYearFrame->new(undef,undef,\@yearsRange);
$frame->Show;
$app->MainLoop;
