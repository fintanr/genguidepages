#!/usr/bin/perl -w
#
# 

use strict;
use YAML qw(LoadFile);
use File::Basename;
use Getopt::Std;
use constant TRUE => 1;
use constant FALSE => 0;
use vars qw/$opt_y $opt_o $opt_d $opt_f $opt_h/;

getopts("y:d:o:fh");

if ( !defined($opt_d) || defined($opt_h) ) {
    usage();
    exit(1);
}

my $outFile = sprintf("%s/README.md", $opt_d);

if ( defined($opt_o) ) {
    $outFile = sprintf("%s/%s", $opt_d, $outFile);
}

if ( -f $outFile && !defined($opt_f) ) {
    printf("File %s already exists, use -f to force overwrite\n", $outFile);
    exit(1);
}

my $doAddHeadings = FALSE;
my $additionalHeadings = "";

if ( defined($opt_y) ) {
    $additionalHeadings = LoadFile($opt_y) || die ("Unable able to open $opt_y\n");
    $doAddHeadings = TRUE;
} 

open(OUT, ">$outFile") || die ("Unable open to write to $outFile");

printf OUT ("# Header #\n\n\n");
printf OUT ("## What you will build ##\n\n\n");
printf OUT ("## What you will use ##\n\n\n");
printf OUT ("## What you will need to complete this guide ##\n\n\n");
printf OUT ("## Step ##\n\n\n");
printf OUT ("## What has happened ##\n\n\n");

if ( $doAddHeadings ) {
   for ( my $i = 0; $i <= $#{$$additionalHeadings{'headings'}}; $i++ ) {
        printf OUT ( "## $$additionalHeadings{'headings'}->[$i] ##\n\n\n");    
    }
}

printf OUT ("## Summary ##\n\n");

close(OUT);

sub usage {
    my $name = basename($0);
    printf("\nUssge: %s -d <outdir> [-y <yaml file>][-o outfile][-f][-h]\n", $name);
    printf("Where: -d directory/write/too\n");
    printf("       -y yaml file of headings\n");
    printf("       -o outfile name (defaults to README.md)\n");
    printf("       -f force overwrite (default is to exit if README.md exists)\n");
    printf("       -h show this help\n\n");
}
