#!/usr/bin/perl -w
#
# Generate the /guides pages
# 
# Takes a README.md from a directory in a repo and formats it 
# for jekyll to use
#

use JSON;
use Getopt::Std;
use File::Basename;
use File::Copy;
use constant TRUE => 1;
use constant FALSE => 0;
use strict;

use vars qw/$opt_c $opt_g $opt_o $opt_h/;

getopts("g:o:c:h");

my $confFile = "guides.json";

if ( !defined($opt_g) || !defined($opt_o) || defined($opt_h) ) {
    usage();
    exit();
}

if ( defined($opt_c) ) {
    $confFile = $opt_c;
}

my $outDir = $opt_o;
my $gitClone = $opt_g;

my $json = loadConfigDetails($confFile);

for ( my $i = 0; $i <= $#{$$json{'guides'}}; $i++ ) {
    my $inFile = sprintf("%s/%s/README.md", $gitClone, $$json{'guides'}->[$i]->{'indir'});
    my $inImage = sprintf("%s/%s/%s", $gitClone, $$json{'guides'}->[$i]->{'indir'}, $$json{'guides'}->[$i]->{'image'});
    my $outFile = sprintf("%s/%s", $outDir, $$json{'guides'}->[$i]->{'outfile'});
    my $outImage = sprintf("%s/%s", $outDir, $$json{'guides'}->[$i]->{'image'});
    my $layout = $$json{'guides'}->[$i]->{'layout'};
    my $markdown = $$json{'guides'}->[$i]->{'markdown'};
    my $highlighter = $$json{'guides'}->[$i]->{'highlighter'};

    my ( $title, $jekyll) = fixupReadMe($inFile);

    open(OUT, ">$outFile") || die ("Unable to open $outFile");
    printf OUT ("---\n");
    printf OUT ("layout: %s\n", $layout);
    printf OUT ("title: %s\n", $title);
    printf OUT ("desciption: Weave Getting Started Guides\n");
    printf OUT ("markdown: %s\n", $markdown);
    printf OUT ("highlighter: %s\n", $highlighter);
    printf OUT ("---\n\n");
    printf OUT ("%s\n", $jekyll);
    close(OUT);

    if ( -f $inImage ) {
        copy($inImage, $outImage);
    }
}

    # grab the relevant readme, and fill in the various bits of 
    # jekyllness that need to be done
    #

sub fixupReadMe {

    my ( $inFile ) = @_;
    my $title = "";
    my $jekyll = "";
    my $doEnd = FALSE;

    open(IN, $inFile) || die ("Unable to open $inFile");
   
    while ( <IN> ) {
        chomp;
        s/\s+$//;
        if ( /^#\s(.*)\s#/ ) {
            $title = $1;
        } elsif ( /^```(bash|javascript|php|java|ruby|python)$/ ) {
            $jekyll .= "{% highlight $1 %}\n";
            $doEnd = TRUE;
        } elsif ( /^```$/ && $doEnd ) {
            $jekyll .= "{% endhighlight %}\n";
            $doEnd = FALSE;
        } elsif ( /(^\!\[.*\])\(.*\/(.*\.png)\)$/ ) {
            $jekyll .= "$1($2)\n\n"; 
        } else {
            $jekyll .= "$_\n";
        }
    }
    close(IN);
    return($title, $jekyll);
}


sub loadConfigDetails {

    my ( $confFile ) = @_;
     
    local $/;
    open( my $fh, '<', $confFile );
    my $jsonText   = <$fh>;
    close($fh);

    my $json = decode_json( $jsonText );
   
    return($json);
}

sub usage {

    my $name = basename($0);

    printf("\nUsage: %s -g <path to local github clonse> -o <out directory> [-c <config file>][-h]\n", $name);
}
