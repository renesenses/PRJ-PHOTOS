#!/usr/bin/perl -w

use strict;
use Wx;

package MyFrame;

use base 'Wx::Frame';
# import the event registration function
use Wx::Event qw(EVT_BUTTON);

sub new {
    my $ref = shift;
    my $self = $ref->SUPER::new( undef,           # parent window
                                 -1,              # ID -1 means any
                                 'wxPerl rules',  # title
                                 [-1, -1],        # default position
                                 [150, 100],      # size
                                 );

    my $panel = Wx::Panel->new( $self,            # parent window
                                -1,               # ID
                                );
    my $button = Wx::Button->new( $panel,         # parent window
                                  -1,             # ID
                                  'Click me!',    # label
                                  [30, 20],       # position
                                  [-1, -1],       # default size
                                  );

    # register the OnClick method as an handler for the
    # 'button clicked' event. The first argument is a Wx::EvtHandler
    # that receives the event
    EVT_BUTTON( $self, $button, \&OnClick );

    return 1;
}

# this method receives as its first parameter the first argument
# passed to the EVT_BUTTON function. The second parameter
# always is a Wx::Event subclass
sub OnClick {
    my( $self, $event ) = @_;

    $self->SetTitle( 'Clicked' );
}

package MyApp;

use base 'Wx::App';

sub OnInit {
    my $frame = MyFrame->new;

    $frame->Show( 1 );
    
    return 1;
}

package main;

my $app = Wx::SimpleApp->new;
my $frame = MyFrame->new( "My FRAME" );

$app->MainLoop;
