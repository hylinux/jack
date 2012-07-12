#!/usr/bin/perl -w
package MikeParseHTML;
use strict;
use utf8;
use base qw/HTML::Parser/;

use LWP::Simple;
use Cwd;
use File::Spec;
use File::Basename;
use File::Path;

#定义替换的hash
my %replace_hash_img;
my %replace_hash_css;
my %replace_hash_javascript;

my $get_url = "http://www.jack-wolfskin.com/Company/Brand/brand-with-the-paw.aspx";
my $write_file = 'brand.html';

my $original_url = "http://www.jack-wolfskin.com/";

my $content = get($get_url);
$content =~ s/&amp;/&/gm;
$content =~s/\r//gm;
$content =~ s/<base href="http:\/\/www\.jack-wolfskin\.com\/" \/>//gm;




#得到了网页的内容，开始解析，并下载图片和CSS，javascript


sub start {
    my($self, $tag, $attr, $attrseq, $origtext) = @_;

    #处理图片的
    if ($tag =~ /^img$/ ) {
        if ( defined $attr->{'src'} ) {
            my $img_src = $attr->{'src'};
            my $img_url = '';
            if ( $img_src =~ /^http/ ) {
                $img_url = $img_src;
            } else {
                $img_url = $original_url.$img_src;
            }
            print "Image Url is:", $img_url, "\n";

            #取得文件的名字
            my $file_ext = "";
            if ( $img_src =~ /\.jpg/gi || $img_src =~ /\.jpeg/gi ) {
                 $file_ext = 'jpg';
            } elsif ( $img_src =~ /\.gif/gi ) {
                 $file_ext = 'gif';
            } elsif ( $img_src =~ /\.png/gi ) {
                 $file_ext = 'png';
            } else {
                $file_ext = 'jpg';
            }

            my $file_name = int(rand(300)).'.'.$file_ext;
            print "File name is:", $file_name, "\n";
            
            getstore($img_url, $file_name);
            $replace_hash_img{$img_src} = $file_name;
        }
    }

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

            #分拆一下css的url，便于处理css中的图片
            my @css_split_result = split /\//, $css_url;
            my $css_url_last_positon =$css_split_result[0];
            for (my $i=1; $i<$#css_split_result; $i++ ) {
                $css_url_last_positon = $css_url_last_positon.'/'.$css_split_result[$i];
            }

            print "CSS file postion is:", $css_url_last_positon, "\n";



            print "CSS url:", $css_url, "\n";
            my $file_name = int(rand(300)).'.css';
            print "File name is:", $file_name, "\n";
            my $css_content = get($css_url);
            $replace_hash_css{$css_src} = $file_name;
            #CSS parser, can get all css image.
            #定义替换CSS的脚本
            my %replace_sub_css_content;
            print "Begin parse the css file:", $file_name, "\n";
            open(my $fh, "<", \$css_content);
            while ( my $line = <$fh> ) {
                if ( $line =~ /background:url\((.*?)\)/ig or 
                        $line =~ /background-image:url\((.*?)\)/gi ) {
                    my $image_url = $1;
                    $image_url =~ s/"//g;
                    $image_url =~ s/'//g;


                    #得到图片的名字
                    my $image_name = '';
                    if ( $image_url =~ /^\.\.\// ) {
                        $image_name = $image_url;
                        $image_name =~ s/(\.\.\/)+(.*?)/$2/;
                    } else {
                        $image_name = $image_url;
                    }
                    my $image_abs_url = $css_url_last_positon.'/'.$image_url;
                    #拉取图片
                    #如果该图片已经存在，则不拉取
                    print "Image Name is:", $image_name, "\n";
                    if ( ! exists($replace_sub_css_content{$image_url} ) ) {
                        my $really_file_name = File::Spec->catfile(getcwd, $image_name);
                        print "Save Really File Name is:", $really_file_name, "\n";
                        #取得目录
                        my $image_dir_name = dirname($really_file_name);
                        #如果目录不存在，则创建该目录
                        if ( !-e $image_dir_name ) {
                            mkpath($image_dir_name);
                        }
                        getstore($image_abs_url, $really_file_name);
                    }
                    $replace_sub_css_content{$image_url} = $image_name;
                }
            }
            close $fh;

            #图片已经全部抓取完毕。现在开始替换
            while ( my($key, $value) = each %replace_sub_css_content ) {
                print "key:", $key, "\n";
                print "value:", $value, "\n";
                $css_content =~ s/\Q$key\E/\Q$value\E/gm;
            }

            open(my $css_wh, ">:encoding(UTF-8)", $file_name);
            print $css_wh $css_content;
            close $css_wh;
            print "Parser the CSS file $file_name is end\n";
        } 
    }


    #解析javascript
    if ( $tag =~ /^script$/ ) {
        if ( $attr->{'type'} =~ /text\/javascript/ ) {
            if ( defined $attr->{'src'} ) {
                my $javascript_src = $attr->{'src'};
                my $javascript_url = ''; 
                if ($javascript_src =~ /^http/i ) {
                    $javascript_url = $javascript_src;
                } else {
                    $javascript_url = $original_url.$javascript_src;
                }

                print "Javascript url:", $javascript_url, "\n";
                my $file_name = int(rand(300)).'.js';
                print "File name is:", $file_name, "\n";
                
                getstore($javascript_url, $file_name);
                $replace_hash_javascript{$javascript_src} = $file_name;
            }
        }
    }

}

my $p  = new MikeParseHTML;
$p->parse($content);
$p->eof;

#解析完成了，但是需要将原页面里的相关内容替换成我们更新后的内容

#处理javascript
while ( my($key, $value) = each %replace_hash_javascript ) {
    print "key:", $key, "\n";
    print "value:", $value, "\n";
    $content =~ s/\Q$key\E/$value/gm;
}

while ( my($key, $value) = each %replace_hash_img ) {
    print "key:", $key, "\n";
    print "value:", $value, "\n";
    $content =~ s/\Q$key\E/$value/gm;
}

while ( my($key, $value) = each %replace_hash_css ) {
    print "key:", $key, "\n";
    print "value:", $value, "\n";
    $content =~ s/\Q$key\E/$value/gm;
}

#写入文件
open(my $fh, ">:encoding(UTF-8)", $write_file) or die "Can't open file for write";
print $fh $content;
close $fh;













