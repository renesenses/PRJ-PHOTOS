#!/usr/bin/perl -w

# Add textCtrl

use strict;
use warnings;

package MyYearFrame;
use Wx qw( :frame :textctrl :listbox :sizer :panel :window :id);
use Wx::Event qw(EVT_CLOSE EVT_BUTTON EVT_LISTBOX);
use base qw( Wx::Frame );
sub new {
    my ($class,$parent,$YearFrameName,$ref_YearsRange) = @_;

    my $self = $class->SUPER::new(
        undef,
        -1,
        $YearFrameName,
        [-1,-1],
        [-1,-1],
        wxDEFAULT_FRAME_STYLE );   
        
    my $topsizer = Wx::BoxSizer->new(wxVERTICAL);
    
    my $panel = Wx::Panel->new(
        $self, -1, [-1,-1], [-1,-1],
        wxTAB_TRAVERSAL|wxBORDER_NONE
    );
    my $yearlabel = Wx::StaticText->new(
 		$panel, 			#parent
        -1,					#id
        "Année : ",			#label
        [-1,-1],			#pos
        [-1,-1],			#size
    );
    $topsizer->Add(
        $yearlabel,
        1,           # make vertically stretchable
        wxEXPAND |   # make horizontally stretchable
        wxALL,       #    and make border all around
        1          # set border width to 10
    );
    my $listbox = Wx::ListBox->new(
        $panel, 			#parent
        -1,					#id
        [-1,-1],			#pos
        [-1,-1],			#size
#        0,					#nb of items
        [ @$ref_YearsRange ],	#items list ref to yearsRange
        ,					#validator         
#       @yearsRange,		#items list instead of pred line 
        wxLB_SINGLE|wxLB_HSCROLL|wxLB_NEEDED_SB|wxLB_SORT
    );
    $topsizer->Add(
        $listbox,
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
    
    
    EVT_LISTBOX($self, $listbox,\&OnYear);
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

sub OnYear {

    my( $this, $event ) = @_;
#    print "ANNEE CHOISIE : ",ref($event),"\n";	
#    print "ITEM No : ",$event->GetSelection,"\n";	 # OK
    print "ANNEE CHOISIE : ",$event->GetString,"\n";	 # OK	
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
# my $frame = MyYearFrame->new();
my $frame = MyYearFrame->new("wxPerlFrameYear","Ces années là",\@yearsRange);
$frame->Show;
$app->MainLoop;
