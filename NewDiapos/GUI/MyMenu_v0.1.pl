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

    my $menu = Wx::Menu->new();
    print "REF MENU : ",ref ($menu),"\n";
    my $menu_item = Wx::MenuItem->new( undef, wxID_ABOUT, "A propos" );
    print "REF MENU ITEM : ",ref ($menu_item),"\n";
    
# parentMenu	Menu that the menu item belongs to. Can be NULL if the item is going to be added to the menu later.
# id			Identifier for this menu item. May be wxID_SEPARATOR, in which case the given kind is ignored and taken to be wxITEM_SEPARATOR instead.
# text			Text for the menu item, as shown on the menu. See SetItemLabel() for more info.
# helpString	Optional help string that will be shown on the status bar.
# kind			May be wxITEM_SEPARATOR, wxITEM_NORMAL, wxITEM_CHECK or wxITEM_RADIO.
# subMenu		If non-NULL, indicates that the menu item is a submenu.
    
    
	$menu->Append(wxID_ANY,"A propos",&Wx::wxITEM_NORMAL);
#    $menu->Append($menu_item);
#    $menu->Append(1, "Item 1");    
    # Display via PopupMenu
#	$self->PopupMenu($menu, -1,-1);
	
    return $self;
}

package main;

my $app = Wx::SimpleApp->new;
my $frame = MyFrame->new();
$frame->Show;
$app->MainLoop;
