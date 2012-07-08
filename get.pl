#!/usr/bin/perl -w
package MikeParseHTML;
use strict;
use utf8;
use LWP::Simple;
use base qw/HTML::Parser/;

#定义替换的hash
my %replace_hash_img;
my %replace_hash_css;
my %replace_hash_javascript;

my $get_url = "http://www.jack-wolfskin.com/Home.aspx";
my $original_url = "http://www.jack-wolfskin.com/";

my $content = get($get_url);

#得到了网页的内容，开始解析，并下载图片和CSS，javascript


sub start {
    my($self, $tag, $attr, $attrseq, $origtext) = @_;

    #处理图片的
#    if ($tag =~ /^img$/ ) {
#        if ( defined $attr->{'src'} ) {
#            my $img_src = $attr->{'src'};
#            my $img_url = '';
#            if ( $img_src =~ /^http/ ) {
#                $img_url = $img_src;
#            } else {
#                $img_url = $original_url.$img_src;
#            }
#            print "Image Url is:", $img_url, "\n";
#
#            #取得文件的名字
#            my $file_ext = "";
#            if ( $img_src =~ /\.jpg/gi || $img_src =~ /\.jpeg/gi ) {
#                 $file_ext = 'jpg';
#            } elsif ( $img_src =~ /\.gif/gi ) {
#                 $file_ext = 'gif';
#            } elsif ( $img_src =~ /\.png/gi ) {
#                 $file_ext = 'png';
#            } else {
#                $file_ext = 'jpg';
#            }
#
#            my $file_name = int(rand(300)).'.'.$file_ext;
#            print "File name is:", $file_name, "\n";
#            
#            getstore($img_url, $file_name);
#            $replace_hash_img{$img_src} = $file_name;
#        }
#    }
#
    #开始处理css和javascript

    if ( $tag =~ /^link$/ ) {

        if (defined $attr->{'type'} && $attr->{'type'} =~ /text\/css/ ) {
            #CSS
            
            #取得CSS的位置
            my $css_src = $attr->{'href'};
            my $css_url = ''; 
            if ($css_src =~ /^http/i ) {
                $css_url = $css_src;
            } else {
                $css_url = $original_url.$css_src;
            }

            print "CSS url:", $css_url, "\n";
            my $file_name = int(rand(300)).'.css';
            print "File name is:", $file_name, "\n";
            
            getstore($css_url, $file_name);
            $replace_hash_css{$css_src} = $file_name;

        } 
    }
}


my $p  = new MikeParseHTML;
$p->parse($content);
$p->eof;







