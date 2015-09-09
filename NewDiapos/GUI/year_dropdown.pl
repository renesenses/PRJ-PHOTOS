#!/usr/bin/perl -w
use strict;

our $CD = "/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog";
# our $CD = "cocoadialog";


# my $rv = `$CD dropdown --title "Preferred OS" --no-newline \\
#	--text "What is your favorite OS?" \\
#	--items "Mac OS X" "GNU/Linux" "Windows" --button1 'That one!' \\
#	--button2 Nevermind`;

my $photo_years;
my @photo_years;
my $year_start = 1963;
my @time = localtime(time);
my $current_year = $time[5]+1900;


print $current_year,"\n";

for my $year ( $year_start .. $current_year ) {
	push @photo_years, "$year";
}

$photo_years = join(" ", @photo_years); 	

print "Range :",$photo_years,"\n";

my $rv = `$CD dropdown \\
				--title "Numérisation de l'évènement" \\
				--no-newline \\
				--pulldown \\
 				--text "Année ?" \\
				--items $photo_years \\
				--button1 'Cette année là !' \\
				--button2 'Annuler'`;
				
print "return RV : ",$rv,"\n"; 
				
my ($button, $item) = split /\n/, $rv;

if ($button == 1) {
	print "Année choisie: ";
	my $res = $year_start + $item;
	print " $res \n";
}	
else {
    print "User canceled\n";
}

