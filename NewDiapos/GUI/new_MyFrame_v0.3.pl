#!/usr/bin/perl
# standard modules
use strict;
use warnings;

# load wxPerl main module
use Wx;

# every application must create an application object

package MyApp;

use Wx qw( :frame :textctrl :listbox :sizer :panel :window :id);
use Wx::Event qw(EVT_CLOSE EVT_BUTTON);
use base qw( Wx::Frame Wx::App );

# The OnInit method is called automatically when an
# application object is first constructed.
# Application level initialization can be done here.

my $YearFrameName = "Ces années là !";
my @yearsRange;
my $yearStart = 1963;
my @time = localtime(time);
my $yearEnd = $time[5]+1900;

for my $year ( $yearStart .. $yearEnd ) {
	push @yearsRange, "$year";
}

sub OnInit {
    my( $self ) = @_;
    
#    print "CLASS : ", $self,"\n";
#    print "PARENT : ", $parent,"\n";    
#    print "NAME : ", $YearFrameName,"\n";
#    print "Items List : ", join(", ",@$ref_YearsRange),"\n";
    
    # create a new frame (a frame is a top level window)
    my $frame = Wx::Frame->new(
        $self,           	# parent window
        -1,              	# ID -1 means any
        $YearFrameName,   	# title
        [-1, -1],        	# default position
        [250, 150],      	# size
        wxDEFAULT_FRAME_STYLE
    );
    
        
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
        $frame, -1, [-1,-1], [-1,-1],
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
        [ @yearsRange ],	#items list ref to yearsRange
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
    
    $frame->Show( 1 );
    
    return $self;
}

sub OnClose {
    my( $this, $event ) = @_;

    $this->Destroy;
}

package main;

# create the application object, this will call OnInit
# before the constructor returns.



my $app = MyApp->new("Diapos");

# process GUI events from the application this function
# will not return until the last frame is closed

$app->MainLoop;
