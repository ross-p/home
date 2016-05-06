#!/usr/bin/php
<?php

$ARGV =& $_SERVER['argv'];

if( ! isset($ARGV[1]) )
  die( "Usage: {$ARGV[0]} sixfour_str\n" );

echo "encoded: {$ARGV[1]}\n"
.    "decoded: " . base64_decode(urldecode($ARGV[1])) . "\n"
;
