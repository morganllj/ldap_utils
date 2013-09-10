#!/usr/bin/perl -w
#

# use strict;
use Digest::SHA1;
use MIME::Base64;
$ctx = Digest::SHA1->new;
$ctx->add('secret');
$ctx->add('something');
$hashedPasswd = '{SSHA}' . encode_base64($ctx->digest . 'something' ,'');
print 'userPassword: ' .  $hashedPasswd . "\n";
