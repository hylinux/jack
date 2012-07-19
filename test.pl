#!/usr/bin/perl -w 
use strict;

my $str = "changeImg(jQuery(this).parent().parent().parent().attr('class'),'http://static.jack-wolfskin.com/web/portaldata/1/resources//products/images/ALL-TERRAIN-TEXAPORE-WOMEN-4002561-6910.jpg?maxwidth=237&amp;maxheight=240&amp;crop=auto')";

if ( $str =~ /^changeImg\((.*?)(\s*)\,(\s*)(.*)\)/i ) {
    print 'ok', "\n";
    print $1,  "\n";
    print $2, "\n";
    print $3, "\n";
    print $4, "\n";
}

