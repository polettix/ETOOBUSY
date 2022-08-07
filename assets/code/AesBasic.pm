package AesBasic;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Exporter 'import';

our %EXPORT_TAGS = (
   factory   => [qw< block_decrypter block_encrypter >],
   one_shot  => [qw< block_decrypt block_encrypt >],
   low_level => [
      qw<
        GF_2_8_mult
        add_round_key
        cipher
        equivalent_inv_cipher
        inv_cipher
        inv_mix_columns
        inv_shift_rows
        inv_sub_bytes
        key_expansion
        mix_columns
        modify_key_schedue_copy
        modify_key_schedue_inplace
        rot_word
        shift_rows
        sub_bytes
        sub_word
        >
   ],
);

$EXPORT_TAGS{high_level} =
  [map { $EXPORT_TAGS{$_}->@* } qw< factory one_shot >];

our @EXPORT_OK = map { $EXPORT_TAGS{$_}->@* } qw< low_level high_level >;

########################################################################
#
# High level API, useful for CryptoPals challenges
#
sub block_decrypt ($ct, $key) { block_decrypter($key)->($ct) }

sub block_decrypter ($key) {
   $key = modify_key_schedule_inplace(key_expansion($key));
   return sub ($ct) { return equivalent_inv_cipher($ct, $key) };
}

sub block_encrypt ($pt, $key) { block_encrypter($key)->($pt) }

sub block_encrypter ($key) {
   $key = key_expansion($key);
   return sub ($plaintext) { return cipher($plaintext, $key) };
}

########################################################################
#
# Low level API, useful for CryptoPals challenges
#
sub _generic_cipher ($input, $key_schedule, $ark, $mxc, $shr, $sby) {
   my $state = [split m{}mxs, $input];
   my ($first, @mids) = $key_schedule->@*;
   my $last = pop @mids;

   $ark->($state, $first);
   $ark->($mxc->($shr->($sby->($state))), $_) for @mids;
   $ark->($shr->($sby->($state)), $last);

   return join '', $state->@*;
} ## end sub _generic_cipher

sub GF_2_8_mult ($x, $y) {
   state $table = GF_2_8_table();
   my ($h, $l) = (ord($x), ord($y));
   ($h, $l) = ($l, $h) if $h < $l;
   return substr $table, $l + $h * ($h + 1) / 2, 1;
} ## end sub GF_2_8_mult

sub add_round_key ($state, $key) {
   my @key = split m{}mxs, $key;
   $state->[$_] ^= $key[$_] for 0 .. $state->$#*;
   return $state;
}

sub cipher ($input, $key_schedule) {
   return _generic_cipher(
      $input,        $key_schedule, \&add_round_key,
      \&mix_columns, \&shift_rows,  \&sub_bytes
   );
} ## end sub cipher

sub equivalent_inv_cipher ($input, $modified_key_schedule) {
   return _generic_cipher($input, $modified_key_schedule, \&add_round_key,
      \&inv_mix_columns, \&inv_shift_rows, \&inv_sub_bytes);
}

sub inv_cipher ($input, $key_schedule) {
   my $state = [split m{}mxs, $input];
   my ($first, @mids) = reverse $key_schedule->@*;
   my $last = pop @mids;

   add_round_key($state, $first);
   inv_mix_columns(
      add_round_key(inv_sub_bytes(inv_shift_rows($state)), $_))
     for @mids;
   add_round_key(inv_sub_bytes(inv_shift_rows($state)), $last);

   return join '', $state->@*;
} ## end sub inv_cipher

sub inv_mix_columns ($state) {
   state $indexes_for = [[0 .. 3], [4 .. 7], [8 .. 11], [12 .. 15]];
   state $_0e         = "\x0e";
   state $_0b         = "\x0b";
   state $_0d         = "\x0d";
   state $_09         = "\x09";
   for my $if ($indexes_for->@*) {
      $state->@[$if->@*] = (
         GF_2_8_mult($_0e, $state->[$if->[0]])
           ^ GF_2_8_mult($_0b, $state->[$if->[1]])
           ^ GF_2_8_mult($_0d, $state->[$if->[2]])
           ^ GF_2_8_mult($_09, $state->[$if->[3]]),
         GF_2_8_mult($_09, $state->[$if->[0]])
           ^ GF_2_8_mult($_0e, $state->[$if->[1]])
           ^ GF_2_8_mult($_0b, $state->[$if->[2]])
           ^ GF_2_8_mult($_0d, $state->[$if->[3]]),
         GF_2_8_mult($_0d, $state->[$if->[0]])
           ^ GF_2_8_mult($_09, $state->[$if->[1]])
           ^ GF_2_8_mult($_0e, $state->[$if->[2]])
           ^ GF_2_8_mult($_0b, $state->[$if->[3]]),
         GF_2_8_mult($_0b, $state->[$if->[0]])
           ^ GF_2_8_mult($_0d, $state->[$if->[1]])
           ^ GF_2_8_mult($_09, $state->[$if->[2]])
           ^ GF_2_8_mult($_0e, $state->[$if->[3]])
      );
   } ## end for my $if ($indexes_for...)
   return $state;
} ## end sub inv_mix_columns ($state)

sub inv_shift_rows ($state) {
   state $sources = [0, 13, 10, 7, 4, 1, 14, 11, 8, 5, 2, 15, 12, 9, 6, 3];
   $state->@* = $state->@[$sources->@*];
   return $state;
}

sub inv_sub_bytes ($state) {
   state $v = <<'END';
      52096ad53036a538bf40a39e81f3d7fb7ce339829b2fff87348e4344c4dee9cb
      547b9432a6c2233dee4c950b42fac34e082ea16628d924b2765ba2496d8bd125
      72f8f66486689816d4a45ccc5d65b6926c704850fdedb9da5e154657a78d9d84
      90d8ab008cbcd30af7e45805b8b34506d02c1e8fca3f0f02c1afbd0301138a6b
      3a9111414f67dcea97f2cfcef0b4e67396ac7422e7ad3585e2f937e81c75df6e
      47f11a711d29c5896fb7620eaa18be1bfc563e4bc6d279209adbc0fe78cd5af4
      1fdda8338807c731b11210592780ec5f60517fa919b54a0d2de57a9f93c99cef
      a0e03b4dae2af5b0c8ebbb3c83539961172b047eba77d626e169146355210c7d
END
   state $value_for = [split m{}mxs, pack 'H*', $v =~ s{\s+}{}grmxs];
   $state->@* = map { $value_for->[ord $_] } $state->@*;
   return $state;
} ## end sub inv_sub_bytes ($state)

sub key_expansion ($key) {
   state $Nb = 4;

   my $Nk = length($key) / $Nb;
   my $Nr = $Nk + 6;
   my @w;

   # bootstrap @w copying the key
   push @w, substr $key, $Nb * $_, $Nb for 0 .. $Nk - 1;

   my $rcon0 = "\x01";
   while (@w < $Nb * ($Nr + 1)) {
      my $i_mod_Nk = @w % $Nk;
      my $temp     = $w[-1];
      if ($i_mod_Nk == 0) {
         $temp = sub_word(rot_word($temp)) ^ ($rcon0 . ("\x00" x 3));
         $rcon0 = GF_2_8_mult($rcon0, "\x02");
      }
      elsif ($Nk > 6 && $i_mod_Nk == 4) {
         $temp = sub_word($temp);
      }
      push @w, $w[-$Nk] ^ $temp;
   } ## end while (@w < $Nb * ($Nr + ...))

   my @schedule;
   push @schedule, join '', splice @w, 0, 4 while @w;
   return \@schedule;
} ## end sub key_expansion ($key)

sub mix_columns ($state) {
   state $indexes_for = [[0 .. 3], [4 .. 7], [8 .. 11], [12 .. 15]];
   state $two         = "\x02";
   state $three       = "\x03";
   for my $if ($indexes_for->@*) {
      $state->@[$if->@*] = (
         GF_2_8_mult($two, $state->[$if->[0]])
           ^ GF_2_8_mult($three, $state->[$if->[1]]) ^ $state->[$if->[2]]
           ^ $state->[$if->[3]],
         $state->[$if->[0]] ^ GF_2_8_mult($two, $state->[$if->[1]])
           ^ GF_2_8_mult($three, $state->[$if->[2]]) ^ $state->[$if->[3]],
         $state->[$if->[0]] ^ $state->[$if->[1]]
           ^ GF_2_8_mult($two,   $state->[$if->[2]])
           ^ GF_2_8_mult($three, $state->[$if->[3]]),
         GF_2_8_mult($three, $state->[$if->[0]]) ^ $state->[$if->[1]]
           ^ $state->[$if->[2]] ^ GF_2_8_mult($two, $state->[$if->[3]])
      );
   } ## end for my $if ($indexes_for...)
   return $state;
} ## end sub mix_columns ($state)

sub modify_key_schedule_copy ($s) { modify_key_schedule_inplace([$s->@*]) }

sub modify_key_schedule_inplace ($schedule) {
   for my $kid (1 .. $schedule->$#* - 1) {    # work on mid stuff only
      my $imc = inv_mix_columns([split m{}mxs, $schedule->[$kid]]);
      $schedule->[$kid] = join '', $imc->@*;
   }
   $schedule->@* = reverse $schedule->@*;
   return $schedule;
} ## end sub modify_key_schedule_inplace ($schedule)

sub rot_word ($word) { substr($word, 1) . substr($word, 0, 1) }

sub shift_rows ($state) {
   state $sources = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11];
   $state->@* = $state->@[$sources->@*];
   return $state;
}

sub sub_bytes ($state) {
   state $v = <<'END';
      637c777bf26b6fc53001672bfed7ab76ca82c97dfa5947f0add4a2af9ca472c0
      b7fd9326363ff7cc34a5e5f171d8311504c723c31896059a071280e2eb27b275
      09832c1a1b6e5aa0523bd6b329e32f8453d100ed20fcb15b6acbbe394a4c58cf
      d0efaafb434d338545f9027f503c9fa851a3408f929d38f5bcb6da2110fff3d2
      cd0c13ec5f974417c4a77e3d645d197360814fdc222a908846eeb814de5e0bdb
      e0323a0a4906245cc2d3ac629195e479e7c8376d8dd54ea96c56f4ea657aae08
      ba78252e1ca6b4c6e8dd741f4bbd8b8a703eb5664803f60e613557b986c11d9e
      e1f8981169d98e949b1e87e9ce5528df8ca1890dbfe6426841992d0fb054bb16
END
   state $value_for = [split m{}mxs, pack 'H*', $v =~ s{\s+}{}grmxs];
   $state->@* = map { $value_for->[ord $_] } $state->@*;
   return $state;
} ## end sub sub_bytes ($state)

sub sub_word ($word) { join '', sub_bytes([split m{}mxs, $word])->@* }

########################################################################
#
# Modulino for testing a few things
#
sub {
   my $db16 = sub { pack 'H*', shift };
   my $eb16 = sub { unpack 'H*', shift };
   my $printout = sub ($thing, $msg = '') {
      $thing = join '', $thing->@* if ref $thing;
      say $msg, unpack 'H*', $thing;
   };

   my $word = 'ABCD';
   say rot_word($word);
   say $eb16->(sub_word($word));

   my $mult = GF_2_8_mult(chr(0x57), chr(0x83));
   say sprintf '%02x', ord($mult);

   my $key      = $db16->('2b7e151628aed2a6abf7158809cf4f3c');
   my $schedule = key_expansion($key);
   say $eb16->($_) for $schedule->@*;
   say $eb16->($key);

   say '';
   my $input = $db16->('3243f6a8885a308d313198a2e0370734');
   say $eb16->($input);
   my $output = cipher($input, $schedule);
   say $eb16->($output);

   my $inverse_official = inv_cipher($output, $schedule);
   say $eb16->($inverse_official);

   my $modified_schedule = modify_key_schedule_copy($schedule);
   my $inverse_equivalent =
     equivalent_inv_cipher($output, $modified_schedule);
   say $eb16->($inverse_equivalent);

   say '';
   say $eb16->($key);
   my $rt = inv_mix_columns(mix_columns([split m{}mxs, $key]));
   say $eb16->(join '', $rt->@*);
   $rt = inv_shift_rows(shift_rows([split m{}mxs, $key]));
   say $eb16->(join '', $rt->@*);
   $rt = inv_sub_bytes(sub_bytes([split m{}mxs, $key]));
   say $eb16->(join '', $rt->@*);

   say '';
   {
      my $plaintext  = $db16->('00112233445566778899aabbccddeeff');
      my $key        = $db16->('000102030405060708090a0b0c0d0e0f');
      my $ciphertext = $db16->('69c4e0d86a7b0430d8cdb78070b4c55a');

      $printout->($plaintext,  'plaintext  ');
      $printout->($key,        'key        ');
      $printout->($ciphertext, 'ciphertext ');

      my $schedule = key_expansion($key);
      my $direct = cipher($plaintext, $schedule);
      $printout->($direct, 'direct     ');

      my $direct2 = cipher($plaintext, $schedule);
      $printout->($direct2, 'direct#2   ');

      my $inv = inv_cipher($ciphertext, $schedule);
      $printout->($inv, 'inverse    ');

      my $mod_schedule = modify_key_schedule_copy($schedule);
      my $inv_eq = equivalent_inv_cipher($ciphertext, $mod_schedule);
      $printout->($inv_eq, 'inverse eq ');
   }

   say '';
   {
      my $plaintext  = $db16->('00112233445566778899aabbccddeeff');
      my $key        = $db16->('000102030405060708090a0b0c0d0e0f');
      my $ciphertext = $db16->('69c4e0d86a7b0430d8cdb78070b4c55a');

      $printout->($plaintext,  'plaintext  ');
      $printout->($key,        'key        ');
      $printout->($ciphertext, 'ciphertext ');

      my $enc = block_encrypt($plaintext, $key);
      $printout->($enc, 'encrypted  ');

      my $dec = block_decrypt($ciphertext, $key);
      $printout->($dec, 'decrypted  ');
   }

   say '';
   {
      my $plaintext  = $db16->('00112233445566778899aabbccddeeff');
      my $key        = $db16->('000102030405060708090a0b0c0d0e0f');
      my $ciphertext = $db16->('69c4e0d86a7b0430d8cdb78070b4c55a');

      $printout->($plaintext,  'plaintext  ');
      $printout->($key,        'key        ');
      $printout->($ciphertext, 'ciphertext ');

      my $encrypter = block_encrypter($key);
      my $decrypter = block_decrypter($key);

      $printout->($encrypter->($plaintext),  'encrypted  ');
      $printout->($decrypter->($ciphertext), 'decrypted  ');
      $printout->($encrypter->($plaintext),  'encrypted  ');
      $printout->($decrypter->($ciphertext), 'decrypted  ');
   }

   say '';
   {
      my $plaintext = $db16->('00112233445566778899aabbccddeeff');
      my $key =
        $db16->('000102030405060708090a0b0c0d0e0f1011121314151617');
      my $ciphertext = $db16->('dda97ca4864cdfe06eaf70a0ec0d7191');

      $printout->($plaintext,  'plaintext  ');
      $printout->($key,        'key        ');
      $printout->($ciphertext, 'ciphertext ');

      my $enc = block_encrypt($plaintext, $key);
      $printout->($enc, 'encrypted  ');

      my $dec = block_decrypt($ciphertext, $key);
      $printout->($dec, 'decrypted  ');
   }

   say '';
   {
      my $plaintext = $db16->('00112233445566778899aabbccddeeff');
      my $key       = $db16->(
         '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f'
      );
      my $ciphertext = $db16->('8ea2b7ca516745bfeafc49904b496089');

      $printout->($plaintext,  'plaintext  ');
      $printout->($key,        'key        ');
      $printout->($ciphertext, 'ciphertext ');

      my $enc = block_encrypt($plaintext, $key);
      $printout->($enc, 'encrypted  ');

      my $dec = block_decrypt($ciphertext, $key);
      $printout->($dec, 'decrypted  ');
   }
  }
  ->() unless caller;

########################################################################
#
# Support function for multiplications over GF(2^8)
#
sub GF_2_8_table {
   my $whole = <<'END';
      000001000204000306050004080c1000050a0f141100060c0a181e140007
      0e091c1b12150008101820283038400009121b242d363f4841000a141e28
      223c36505a44000b161d2c273a3158534e45000c1814303c2824606c7874
      50000d1a1734392e236865727f5c51000e1c123836242a707e6c62484654
      000f1e113c33222d78776669444b5a5500102030405060708090a0b0c0d0
      e0f01b00112233445566778899aabbccddeeff0b1a00122436485a6c7e90
      82b4a6d8cafcee3b291f001326354c5f6a79988bbeadd4c7f2e12b380d1e
      0014283c5044786ca0b4889cf0e4d8cc5b4f73670b00152a3f54417e6ba8
      bd8297fce9d6c34b5e61741f0a00162c3a584e7462b0a69c8ae8fec4d27b
      6d574123350f00172e395c4b7265b8af9681e4f3cadd6b7c45523720190e
      0018302860785048c0d8f0e8a0b890889b83abb3fbe3cbd35b0019322b64
      7d564fc8d1fae3acb59e878b92b9a0eff6ddc4435a001a342e68725c46d0
      cae4feb8a28c96bba18f95d3c9e7fd6b715f001b362d6c775a41d8c3eef5
      b4af8299abb09d86c7dcf1ea7368455e001c3824706c4854e0fcd8c4908c
      a8b4dbc7e3ffabb7938f3b27031f4b001d3a2774694e53e8f5d2cf9c81a6
      bbcbd6f1ecbfa28598233e1904574a001e3c227866445af0eeccd28896b4
      aafbe5c7d9839dbfa10b153729736d4f001f3e217c63425df8e7c6d9849b
      baa5ebf4d5ca9788a9b6130c2d326f70514e0020406080a0c0e01b3b5b7b
      9bbbdbfb36167656b696f6d62d0d6d4dad8dedcd6c0021426384a5c6e713
      32517097b6d5f426076445a283e0c135147756b190f3d24c6d0022446688
      aaccee0b294f6d83a1c7e5163452709ebcdaf81d3f597b95b7d1f32c0e68
      002346658cafcae9032045668facc9ea062540638aa9ccef0526436089aa
      cfec0c2f4a690024486c90b4d8fc3b1f7357ab8fe3c776523e1ae6c2ae8a
      4d690521ddf995b1ecc8a4807c00254a6f94b1defb3316795ca782edc866
      432c09f2d7b89d55701f3ac1e48baecce986a3587d00264c6a98bed4f22b
      0d6741b395ffd956701a3ccee882a47d5b3117e5c3a98fac8ae0c6341278
      00274e699cbbd2f523046d4abf98f1d64661082fdafd94b365422b0cf9de
      b7908cabc2e510375e7900285078a088f0d85b730b23fbd3ab83b69ee6ce
      163e466eedc5bd954d651d35775f270fd7ff87af2c0029527ba48df6df53
      7a0128f7dea58ca68ff4dd022b5079f5dca78e5178032a577e052cf3daa1
      88042d002a547ea882fcd64b611f35e3c9b79d96bcc2e83e146a40ddf789
      a3755f210b371d63499fb5cbe17c5628002b567dac87fad14368153eefc4
      b99286add0fb2a017c57c5ee93b869423f14173c416abb90edc6547f0229
      002c5874b09ce8c47b57230fcbe793bff6daae82466a1e328da1d5f93d11
      6549f7dbaf83476b1f338ca0d4f83c002d5a77b499eec3735e2904c7ea9d
      b0e6cbbc91527f082595b8cfe2210c7b56d7fa8da0634e3914a489fed310
      3d002e5c72b896e4ca6b453719d3fd8fa1d6f88aa46e40321cbd93e1cf05
      2b5977b799ebc50f21537ddcf280ae644a38002f5e71bc93e2cd634c3d12
      dff081aec6e998b77a55240ba58afbd41936476897b8c9e62b04755af4db
      aa854867163900306050c0f0a0909babfbcb5b6b3b0b2d1d4d7deddd8dbd
      b686d6e6764616265a6a3a0a9aaafacac1f1a191013161517700316253c4
      f5a69793a2f1c0576635043d0c5f6ef9c89baaae9fccfd6a5b08397a4b18
      29be8fdcede9d88bba2d1c4f7e477600326456c8faac9e8bb9efdd437127
      150d3f695bc5f7a19386b4e2d04e7c2a181a287e4cd2e0b68491a3f5c759
      6b3d0f17257300336655ccffaa9983b0e5d64f7c291a1d2e7b48d1e2b784
      9eadf8cb526134073a095c6ff6c590a3b98adfec75461320271441720034
      685cd0e4b88cbb8fd3e76b5f03376d590531bd89d5e1d6e2be8a06326e5a
      daeeb2860a3e62566155093db185d9edb783dfeb6700356a5fd4e1be8bb3
      86d9ec67520d387d481722a99cc3f6cefba4911a2f7045facf90a52e1b44
      71497c23169da8f7c287b2edd8536600366c5ad8eeb482ab9dc7f173451f
      294d7b211795a3f9cfe6d08abc3e0852649aacf6c042742e1831075d6be9
      df85b3d7e1bb8d0f396300376e59dcebb285a394cdfa7f4811265d6a3304
      81b6efd8fec990a722154c7bba8dd4e36651083f192e7740c5f2ab9ce7d0
      89be3b0c556200387048e0d890a8dbe3ab933b034b73ad95dde54d753d05
      764e063e96aee6de41793109a199d1e99aa2ead27a420a32ecd49ca40c34
      7c44370039724be4dd96afd3eaa198370e457cbd84cff659602b126e571c
      258ab3f8c16158132a85bcf7ceb28bc0f9566f241ddce5ae9738014a730f
      36003a744ee8d29ca6cbf1bf852319576d8db7f9c3655f112b467c3208ae
      94dae0013b754fe9d39da7caf0be842218566c8cb6f8c2645e102a477d33
      003b764decd79aa1c3f8b58e2f1459629da6ebd0714a073c5e652813b289
      c4ff211a576ccdf6bb80e2d994af0e357843bc87caf1506b261d7f440932
      003c7844f0cc88b4fbc783bf0b37734fedd195a91d216559162a6e52e6da
      9ea2c1fdb985310d49753a06427ecaf6b28e2c105468dce0a498d7ebaf93
      27003d7a47f4c98eb3f3ce89b4073a7d40fdc087ba0934734e0e337449fa
      c780bde1dc9ba615286f52122f6855e6db9ca11c21665be8d592afefd295
      a81b26003e7c42f8c684baebd597a9132d6f51cdf3b18f350b497726185a
      64dee0a29c81bffdc37947053b6a54162892aceed04c72300eb48ac8f6a7
      99dbe55f6123003f7e41fcc382bde3dc9da21f20615edde2a39c211e5f60
      3e01407fc2fdbc83a19edfe05d62231c427d3c03be81c0ff7c43023d80bf
      fec19fa0e1de635c1d22004080c01b5b9bdb3676b6f62d6daded6c2cecac
      7737f7b75a1ada9a4101c181d8985818c3834303eeae6e2ef5b57535b4f4
      3474afef2f6f82c2024299d91959ab004182c31f5e9ddc3e7fbcfd2160a3
      e27c3dfebf6322e1a04203c0815d1cdf9ef8b97a3be7a66524c6874405d9
      985b1a84c506479bda1958bafb3879a5e42766ebaa004284c6135197d526
      64a2e03577b1f34c0ec88a5f1ddb996a28eeac793bfdbf98da1c5e8bc90f
      4dbefc3a78adef296bd4965012c7854301f2b07634e1a365272b69af0043
      86c5175491d22e6da8eb397abffc5c1fda994b08cd8e7231f4b76526e3a0
      b8fb3e7dafec296a96d5105381c20744e4a76221f3b07536ca894c0fdd9e
      5b186b28edae004488cc0b4f83c716529eda1d5995d12c68a4e02763afeb
      3a7eb2f63175b9fd581cd0945317db9f4e0ac6824501cd897430fcb87f3b
      f7b36226eaae692de1a5b0f4387cbb00458acf0f4a85c01e5b94d111549b
      de3c79b6f33376b9fc2267a8ed2d68a7e2783df2b77732fdb86623eca969
      2ce3a64401ce8b4b0ec1845a1fd0955510df9af0b57a3fffba00468cca03
      458fc906408acc054389cf0c4a80c60f4983c50a4c86c0094f85c3185e94
      d21b5d97d11e5892d41d5b91d7145298de17519bdd12549ed811579ddb30
      76bcfa3375bf00478ec9074089ce0e4980c7094e87c01c5b92d51b5c95d2
      12559cdb15529bdc387fb6f13f78b1f63671b8ff3176bff82463aaed2364
      adea2a6da4e32d6aa3e47037feb97730f9be004890d83b73abe3763ee6ae
      4d05dd95eca47c34d79f470f9ad20a42a1e93179c38b531bf8b06820b5fd
      256d8ec61e562f67bff7145c84cc5911c981622af2ba9dd50d45a6ee367e
      eb004992db3f76ade47e37eca54108d39afcb56e27c38a511882cb1059bd
      f42f66e3aa7138dc954e079dd40f46a2eb30791f568dc42069b2fb6128f3
      ba5e17cc85dd944f06e2ab7039a3ea004a94de3379a7ed662cf2b8551fc1
      8bcc865812ffb56b21aae03e7499d30d4783c9175db0fa246ee5af713bd6
      9c42084f05db917c36e8a22963bdf71a508ec41d5789c32e64baf07b31ef
      004b96dd377ca1ea6e25f8b35912cf84dc974a01eba07d36b2f9246f85ce
      1358a3e8357e94df0249cd865b10fab16c277f34e9a24803de95115a87cc
      266db0fb5d16cb806a21fcb73378a5ee004c98d42b67b3ff561ace827d31
      e5a9ace0347887cb1f53fab6622ed19d4905430fdb976824f0bc15598dc1
      3e72a6eaefa3773bc4885c10b9f5216d92de0a4686ca1e52ade13579d09c
      4804fb004d9ad72f62b5f85e13c489713ceba6bcf1266b93de0944e2af78
      35cd80571a632ef9b44c01d69b3d70a7ea125f88c5df924508f0bd6a2781
      cc1b56aee33479c68b5c11e9a4733e98d5024fb7fa004e9cd2236dbff146
      08da94652bf9b78cc2105eafe1337dca845618e9a7753b034d9fd1206ebc
      f2450bd9976628fab48fc1135dace2307ec987551beaa4763806489ad425
      6bb9f7400edc92632dff004f9ed12768b9f64e01d09f6926f7b89cd3024d
      bbf4256ad29d4c03f5ba6b24236cbdf2044b9ad56d22f3bc4a05d49bbff0
      216e98d70649f1be6f20d69948074609d897612effb0084796d92f60b1fe
      0050a0f05b0bfbabb6e61646edbd4d1d7727d7872c7c8cdcc19161319aca
      3a6aeebe4e1eb5e515455808f8a80353a3f399c93969c29262322f7f8fdf
      7424d484c79767379ccc3c6c7121d1812a7a8adab00051a2f35f0efdacbe
      ef1c4de1b043126736c59438699acbd9887b2a86d72475ce9f6c3d91c033
      627021d2832f7e8ddca9f80b5af6a754051746b5e44819eabb87d62574d8
      897a2b39689bca6637c495e0b10052a4f65301f7a5a6f40250f5a7510357
      05f3a10456a0f2f1a35507a2f00654aefc0a58fdaf590b085aacfe5b09ff
      adf9ab5d0faaf80e5c5f0dfba90c5ea8fa4715e3b11446b0e2e1b34517b2
      e016441042b40053a6f55704f1a2aefd085bf9aa5f0c4714e1b21043b6e5
      e9ba4f1cbeed184b8edd287bd98a7f2c207386d57724d182c99a6f3c9ecd
      386b6734c192306396c50754a1f25003f6a5a9fa0f5cfead580b4013e6b5
      0054a8fc4b1fe3b796c23e6add89752137639fcb7c28d480a1f5095deabe
      42166e3ac69225718dd9f8ac5004b3e71b4f590df1a51246baeecf9b6733
      84d02c78dc88742097c33f6b4a1ee2b60155a9fdebbf4317a00055aaff4f
      1ae5b09ecb3461d1847b2e27728dd8683dc297b9ec1346f6a35c094e1be4
      b10154abfed0857a2f9fca3560693cc39626738cd9f7a25d08b8ed12479c
      c93663d386792c0257a8fd4d18e7b2bbee1144f4a10056acfa4315efb986
      d02a7cc593693f1741bbed5402f8ae91c73d6bd2847e282e7882d46d3bc1
      97a8fe0452ebbd4711396f95c37a2cd680bfe91345fcaa50065c0af0a61f
      49b3e5da8c762099cf35634b1de7b1085ea40057aef94710e9be8ed92077
      c99e67300750a9fe4017eeb989de2770ce9960370e59a0f7491ee7b080d7
      2e79c790693e095ea7f04e19e0b787d0297ec0976e391c4bb2e55b0cf5a2
      92c53c6bd5827b2c1b4cb5e25c0bf2a50058b0e87b23cb93f6ae461e8dd5
      3d65f7af471f8cd43c640159b1e97a22ca92f5ad451d8ed63e66035bb3eb
      7820c890025ab2ea7921c991f4ac441c8fd73f67f1a941198ad23a62075f
      b7ef7c24cc94065eb6ee7d25cd95f00059b2eb7f26cd94fea74c1581d833
      6ae7be550c98c12a731940abf2663fd48dd58c673eaaf318412b7299c054
      0de6bf326b80d94d14ffa6cc957e27b3ea0158b1e8035ace977c254f16fd
      a4306982db560fe4bd29709bc2a8f1005ab4ee7329c79de6bc520895cf21
      7bd78d6339a4fe104a316b85df4218f6acb5ef015bc69c72285309e7bd20
      7a94ce6238d68c114ba5ff84de306af7ad4319712bc59f0258b6ec97cd23
      79e4be500aa6fc1248d58f613b401af4005bb6ed772cc19aeeb5580399c2
      2f74c79c712ab0eb065d29729fc45e05e8b395ce2378e2b9540f7b20cd96
      0c57bae15209e4bf257e93c8bce70a51cb907d26316a87dc461df0abdf84
      6932a8f31e45f6ad401b81da376c1843aef5005cb8e46b37d38fd68a6e32
      bde10559b7eb0f53dc806438613dd9850a56b2ee7529cd911e42a6faa3ff
      1b47c894702cc29e7a26a9f5114d1448acf07f23c79beab6520e81dd3965
      3c6084d8570befb35d01e5b9366a8ed28bd7336fe0005dbae76f32d588de
      836439b1ec0b56a7fa1d40c895722f7924c39e164bacf15508efb23a6780
      dd8bd6316ce4b95e03f2af48159dc0277a2c7196cb431ef9a4aaf7104dc5
      987f227429ce931b46a1fc0d50b7ea623fd885d38e6934bce1005ebce263
      3ddf81c6987a24a5fb194797c92b75f4aa4816510fedb3326c8ed0356b89
      d75608eab4f3ad4f1190ce2c72a2fc1e40c19f7d23643ad8860759bbe56a
      34d6880957b5ebacf2104ecf91732dfda3411f9ec0227c3b6587d95806e4
      005fbee16738d986ce91702fa9f6174887d83966e0bf5e014916f7a82e71
      90cf154aabf4722dcc93db84653abce3025d92cd2c73f5aa4b145c03e2bd
      3b6485da2a7594cb4d12f3ace4bb5a0583dc3d62adf2134cca95742b633c
      dd82045bbae50060c0a09bfb5b3b2d4ded8db6d676165a3a9afac1a10161
      7717b7d7ec8c2c4cb4d474142f4fef8f99f959390262c2a2ee8e2e4e7515
      b5d5c3a30363583898f87313b3d3e88828485e3e9efec5a505652949e989
      b2d272120464c4a49fff5f3fc70061c2a39ffe5d3c2544e786badb78194a
      2b88e9d5b417766f0eadccf091325394f556370b6ac9a8b1d073122e4fec
      8ddebf1c7d412083e2fb9a39586405a6c73352f190accd6e0f1677d4b589
      e84b2a7918bbdae68724455c3d9effc3a20160a7c60062c4a693f157353d
      5ff99baecc6a087a18bedce98b2d4f472583e1d4b61072f49630526705a3
      c1c9ab0d6f5a389efc8eec4a281d7fd9bbb3d177152042e486f391375560
      02a4c6ceac0a685d3f99fb89eb4d2f1a78debcb4d670122745e3810765c3
      0063c6a597f451323556f390a2c164076a09accffd9e3b585f3c99fac8ab
      0e6dd4b71271432085e6e18227447615b0d3bedd781b294aef8c8be84d2e
      1c7fdab9b3d075162447e28186e540231172d7b4d9ba1f7c4e2d88ebec8f
      2a497b18bdde6704a1c20064c8ac8bef43270d69c5a186e24e2a1a7ed2b6
      91f5593d1773dfbb9cf854303450fc98bfdb7713395df195b2d67a1e2e4a
      e682a5c16d092347eb8fa8cc6004680ca0c4e3872b4f6501adc9ee8a2642
      7216badef99d31557f1bb7d3f4903c585c3894f0d70065caaf8fea452005
      60cfaa8aef40250a6fc0a585e04f2a0f6ac5a080e54a2f1471debb9bfe51
      341174dbbe9efb54311e7bd4b191f45b3e1b7ed1b494f15e3b284de287a7
      c26d082d48e782a2c7680d2247e88dadc867022742ed88a8cd62073c59f6
      93b3d60066ccaa83e54f291d7bd1b79ef852343a5cf690b9df75132741eb
      8da4c2680e7412b8def7913b5d690fa5c3ea8c26404e2882e4cdab016753
      359ff9d0b61c7ae88e24426b0da7c1f593395f7610badcd2b41e7851379d
      fbcfa903654c2a80e69cfa50361f79d30067cea987e0492e1572dbbc92f5
      5c3b2a4de483adca63043f58f196b8df761154339afdd3b41d7a41268fe8
      c6a1086f7e19b0d7f99e37506b0ca5c2ec8b2245a8cf66012f48e186bdda
      73143a5df49382e54c2b0562cbac97f0593e1077deb9fc9b32557b1cb5d2
      0068d0b8bbd36b036d05bdd5d6be066edab20a626109b1d9b7df670f0c64
      dcb4afc77f17147cc4acc2aa127a7911a9c1751da5cdcea61e761870c8a0
      a3cb731b452d95fdfe962e462840f89093fb432b9ff74f27244cf49cf29a
      224a492199f1ea823a52513981e9870069d2bbbfd66d04650cb7dedab308
      61caa31871751ca7ceafc67d141079c2ab8fe65d343059e28bea83385155
      3c87ee452c97fefa9328412049f29b9ff64d24056cd7bebad368016009b2
      dbdfb60d64cfa61d747019a2cbaac37811157cc7ae8ae35831355ce78eef
      86006ad4beb3d9670d7d17a9c3cea41a70fa902e4449239df787ed533934
      5ee08aef853b515c3688e292f8462c214bf59f157fc1aba6cc72186802bc
      d6dbb10f65c5af117b761ca2c8b8d26c060b61dfb53f55eb818ce6583242
      2896fcf19b254f2a40fe9499f34d27573d83006bd6bdb7dc610a751ea3c8
      c2a9147fea813c575d368be09ff449222843fe95cfa419727813aec5bad1
      6c070d66dbb0254ef39892f9442f503b86ede78c315a85ee53383259e48f
      f09b264d472c91fa6f04b9d2d8b30e651a71cca7adc67b104a219cf7fd96
      2b403f54e982006cd8b4abc7731f4d2195f9e68a3e529af6422e315de985
      d7bb0f637c10a4c82f43f79b84e85c30620ebad6c9a5117db5d96d011e72
      c6aaf894204c533f8be75e3286eaf5992d41137fcba7b8d4600cc4a81c70
      6f03b7db89e5513d224efa96711da9c5dab6026e3c50e48897006ddab7af
      c2751845289ff2ea87305d8ae7503d2548ff92cfa21578600dbad70f62d5
      b8a0cd7a174a2790fde5883f5285e85f322a47f09dc0ad1a776f02b5d81e
      73c4a9b1dc6b065b3681ecf4992e4394f94e233b56e18cd1bc0b667e13a4
      c9117ccba6bed3640954398ee3fb96006edcb2a3cd7f115d3381effe9022
      4cbad466081977c5abe7893b55442a98f66f01b3ddcca2107e325cee8091
      ff4d23d5bb09677618aac488e6543a2b45f799deb0026c7d13a1cf83ed5f
      31204efc92640ab8d6c7a91b753957e58b9af44628b1df6d03127ccea0ec
      82305e4f2193006fdeb1a7c87916553a8be4f29d2c43aac5741b0d62d3bc
      ff90214e583786e94f2091fee88736591a75c4abbdd2630ce58a3b54422d
      9cf3b0df6e011778c9a69ef1402f3956e788cba4157a6c03b2dd345bea85
      93fc4d22610ebfd0c6a91877d1be0f607619a8c784eb5a35234cfd920070
      e090dbab3b4baddd4d3d760696e64131a1d19aea7a0aec9c0c7c3747d7a7
      82f262125929b9c92f5fcfbff4841464c3b323531868f8886e1e8efeb5c5
      55251f6fff8fc4b42454b2c25222691989f95e2ebece85f56515f3831363
      2858c8b89ded7d0d4636a6d63040d0a0eb9b0b7bdc0071e293dfae3d4ca5
      d447367a0b98e95120b3c28eff6c1df48516672b5ac9b8a2d340317d0c9f
      ee0776e594d8a93a4bf38211602c5dcebf5627b4c589f86b1a5f2ebdcc80
      f16213fa8b18692554c7b60e7fec9dd1a03342abda4938740596e7fd8c1f
      6e2253c0b15829bacb87f66514acdd0072e496d3a13745bdcf592b6e1c8a
      f8611385f7b2c05624dcae384a0f7deb99c2b026541163f5877f0d9be9ac
      de483aa3d14735700294e61e6cfa88cdbf295b9fed7b094c3ea8da2250c6
      b4f1831567fe8c1a682d5fc9bb4331a7d590e274065d2fb9cb8efc6a18e0
      9204763341d7a53c4ed80073e695d7a43142b5c65320621184f7710297e4
      a6d54033c4b722511360f586e29104773546d3a05724b1c280f3661593e0
      75064437a2d12655c0b3f1821764dfac394a087bee9d6a198cffbdce5b28
      aedd483b790a9fec1b68fd8eccbf2a593d4edba8ea990c7f88fb6e1d5f2c
      b9ca4c3faad90074e89ccbbf23578df965114632aeda0175e99dcabe2256
      8cf864104733afdb0276ea9ec9bd21558ffb67134430acd80377eb9fc8bc
      20548efa66124531add90470ec98cfbb275389fd61154236aade0571ed99
      ceba265288fc60144337abdf0672ee9acdb925518bff63174034a8dc0773
      ef9bcc0075ea9fcfba255085f06f1a4a3fa0d51164fb8edeab344194e17e
      0b5b2eb1c42257c8bded980772a7d24d38681d82f73346d9acfc891663b6
      c35c29790c93e64431aedb8bfe6114c1b42b5e0e7be4915520bfca9aef70
      05d0a53a4f1f6af58066138cf9a9dc4336e396097c2c59c6b377029de8b8
      cd0076ec9ac3b52f599deb71075e28b2c42157cdbbe2940e78bcca50267f
      0993e54234aed881f76d1bdfa933451c6af08663158ff9a0d64c3afe8812
      643d4bd1a784f2681e4731abdd196ff583daac3640a5d3493f66108afc38
      4ed4a2fb8d1761c6b02a5c0573e99f5b2db7c198ee7402e7910b7d2452c8
      0077ee99c7b0295e95e27b0c5225bccb3146dfa8f681186fa4d34a3d6314
      8dfa62158cfba5d24b3cf780196e3047dea95324bdca94e37a0dc6b1285f
      0176ef98c4b32a5d0374ed9a5126bfc896e1780ff5821b6c3245dcab6017
      8ef9a7d0493ea6d1483f61168ff83344ddaaf4831a6d97e0790e5027bec9
      0078f088fb830b73ed951d65166ee69ec1b931493a42cab22c54dca4d7af
      275f99e16911621a92ea740c84fc8ff77f075820a8d0a3db532bb5cd453d
      4e36bec62951d9a1d2aa225ac4bc344c3f47cfb7e8901860136be39b057d
      f58dfe860e76b0c840384b33bbc35d25add5a6de562e710981f98af27a02
      9c0079f28bff860d74e59c176e1a63e891d1a8235a2e57dca5344dc6bfcb
      b23940b9c04b32463fb4cd5c25aed7a3da512868119ae397ee651c8df47f
      06720b80f969109be296ef641d8cf57e07730a81f8b8c14a33473eb5cc5d
      24afd6a2db5029d0a9225b2f56dda4354cc7becab338410178f38afe870c
      75e49d007af48ef389077dfd8709730e74fa80e19b156f1268e69c1c66e8
      92ef951b61d9a32d572a50dea4245ed0aad7ad23593842ccb6cbb13f45c5
      bf314b364cc2b8a9d35d275a20aed4542ea0daa7dd53294832bcc6bbc14f
      35b5cf413b463cb2c8700a84fe83f9770d8df779037e048af091eb651f62
      1896ec6c1698007bf68df78c017af58e03780279f48ff18a077c067df08b
      047ff289f388057ef9820f740e75f8830c77fa81fb800d760873fe85ff84
      0972fd860b700a71fc87e9921f641e65e8931c67ea91eb901d661863ee95
      ef941962ed961b601a61ec97106be69de79c116ae59e13681269e49fe19a
      176c166de09b146fe299007cf884eb97136fcdb13549265adea281fd7905
      6a1692ee4c30b4c8a7db5f231965e19df28e0a76d4a82c503f43c7bb98e4
      601c730f8bf75529add1bec2463a324ecab6d9a5215dff83077b1468ec90
      b3cf4b375824a0dc7e0286fa95e96d112b57d3afc0bc3844e69a1e620d71
      f589aad6522e413db9c5671b9fe38c007dfa87ef921568c5b83f422a57d0
      ad91ec6b167e0384f95429aed3bbc6413c3944c3bed6ab2c51fc81067b13
      6ee994a8d5522f473abdc06d1097ea82ff7805720f88f59de0671ab7ca4d
      305825a2dfe39e19640c71f68b265bdca1c9b4334e4b36b1cca4d95e238e
      f37409611c9be6daa7205d3548cfb21f62e598f08d007efc82e39d1f61dd
      a3215f3e40c2bca1df5d23423cbec07c0280fe9fe1631d5927a5dbbac446
      3884fa780667199be5f886047a1b65e799255bd9a7c6b83a44b2cc4e3051
      2fadd36f1193ed8cf2700e136def91f08e0c72ceb0324c2d53d1afeb9517
      690876f48a3648cab4d5ab29574a34b6c8a9d7552b97e96b15740a88007f
      fe81e7981966d5aa2b54324dccb3b1ce4f305629a8d7641b9ae583fc7d02
      790687f89ee1601facd3522d4b34b5cac8b736492f50d1ae1d62e39cfa85
      047bf28d0c73156aeb942758d9a6c0bf3e41433cbdc2a4db5a2596e96817
      710e8ff08bf4750a6c1392ed5e21a0dfb9c647383a45c4bbdda2235cef90
      116e0877f68900801b9b36b62dad6cec77f75ada41c1d858c343ee6ef575
      b434af2f82029919ab2bb0309d1d8606c747dc5cf171ea6a73f368e845c5
      5ede1f9f048429a932b24dcd56d67bfb60e021a13aba17970c8c95158e0e
      a323b838f979e262cf4fd454e666fd7dd050cb4b8a0a9111bc3ca7273ebe
      25a50888139352d249c964e47fff9a0081199832b32baa64e57dfc56d74f
      cec849d150fa7be362ac2db5349e1f87068b0a9213b938a021ef6ef677dd
      5cc44543c25adb71f068e927a63ebf15940c8d0d8c14953fbe26a769e870
      f15bda42c3c544dc5df776ee6fa120b83993128a0b86079f1eb435ad2ce2
      63fb7ad051c9484ecf57d67cfd65e42aab33b2189901801a9b00821f9d3e
      bc21a37cfe63e142c05ddff87ae765c644d95b84069b19ba38a527eb69f4
      76d557ca489715880aa92bb63413910c8e2daf32b06fed70f251d34ecccd
      4fd250f371ec6eb133ae2c8f0d901235b72aa80b89149649cb56d477f568
      ea26a439bb189a07855ad845c764e67bf9de5cc143e062ff7da220bd3f9c
      1e830181039e00831d9e3ab927a474f769ea4ecd53d0e86bf576d251cf4c
      9c1f8102a625bb38cb48d655f172ec6fbf3ca2218506981b23a03ebd199a
      048757d44ac96dee70f38d0e9013b734aa29f97ae467c340de5d65e678fb
      5fdc42c111920c8f2ba836b546c55bd87cff61e232b12fac088b1596ae2d
      b3309417890ada59c744e063fd7e01821c9f0084139726a235b14cc85fdb
      6aee79fd981c8b0fbe3aad29d450c743f276e1652baf38bc0d891e9a67e3
      74f041c552d6b337a02495118602ff7bec68d95dca4e56d245c170f463e7
      1a9e098d3cb82fabce4add59e86cfb7f82069115a420b7337df96eea5bdf
      48cc31b522a617930480e561f672c347d054a92dba3e8f0b9c18ac28bf3b
      8a0085119422a733b644c155d066e377f2880d991caa2fbb3ecc49dd58ee
      6bff7a0b8e1a9f29ac38bd4fca5edb6de87cf983069217a124b035c742d6
      53e560f4711693078234b125a052d743c670f561e49e1b8f0abc39ad28da
      5fcb4ef87de96c1d980c893fba2eab59dc48cd7bfe6aef95108401b732a6
      23d154c045f376e2672ca93db80e8b008617912ea839bf5cda4bcd72f465
      e3b83eaf2996108107e462f375ca4cdd5b6bed7cfa45c352d437b120a619
      9f0e88d355c442fd7bea6c8f09981ea127b630d650c147f87eef698a0c9d
      1ba422b3356ee879ff40c657d132b425a31c9a0b8dbd3baa2c93158402e1
      67f670cf49d85e058312942bad3cba59df4ec877f160e6b731a026991f8e
      008715922aad3fb854d341c67ef96beca82fbd3a82059710fc7be96ed651
      c3444bcc5ed961e674f31f980a8d35b220a7e364f671c94edc5bb730a225
      9d1a880f96118304bc3ba92ec245d750e86ffd7a3eb92bac149301866aed
      7ff840c755d2dd5ac84ff770e265890e9c1ba324b63175f260e75fd84acd
      21a634b30b8c1e9937b022a51d9a088f00880b83169e1d952ca427af3ab2
      31b958d053db4ec645cd74fc7ff762ea69e1b038bb33a62ead259c14971f
      8a028109e860e36bfe76f57dc44ccf47d25ad9517bf370f86de566ee57df
      5cd441c94ac223ab28a035bd3eb60f87048c1991129acb43c048dd55d65e
      e76fec64f179fa72931b9810850d8e06bf37b43ca921a22af67efd75e068
      eb63da00890980129b1b9224ad2da436bf3fb648c141c85ad353da6ce565
      ec7ef777fe90199910820b8b02b43dbd34a62faf26d851d158ca43c34afc
      75f57cee67e76e3bb232bb29a020a91f96169f0d84048d73fa7af361e868
      e157de5ed745cc4cc5ab22a22bb930b0398f06860f9d14941de36aea63f1
      78f871c74ece47d55cdc5576ff7ff664ed6de452db008a0f851e94119b3c
      b633b922a82da778f277fd66ec69e344ce4bc15ad055dff07aff75ee64e1
      6bcc46c349d258dd578802870d961c9913b43ebb31aa20a52ffb71f47ee5
      6fea60c74dc842d953d65c83098c069d179218bf35b03aa12bae240b8104
      8e159f1a9037bd38b229a326ac73f97cf66de762e84fc540ca51db5ed4ed
      67e268f379fc76d15bde008b0d861a91179c34bf39b22ea523a868e365ee
      72f97ff45cd751da46cd4bc0d05bdd56ca41c74ce46fe962fe75f378b833
      b53ea229af248c07810a961d9b10bb30b63da12aac278f048209951e9813
      d358de55c942c44fe76cea61fd76f07b6be066ed71fa7cf75fd452d945ce
      48c303880e851992149f37bc3ab12da620ab6de660eb77fc7af159d254df
      008c038f068a05890c800f830a86098518941b971e921d911498179b129e
      119d30bc33bf36ba35b93cb03fb33ab639b528a42ba72ea22da124a827ab
      22ae21ad60ec63ef66ea65e96ce06fe36ae669e578f47bf77ef27df174f8
      77fb72fe71fd50dc53df56da55d95cd05fd35ad659d548c44bc74ec24dc1
      44c847cb42ce41cdc04cc34fc64ac549cc40cf43ca008d018c028f038e04
      890588068b078a088509840a870b860c810d800e830f82109d119c129f13
      9e14991598169b179a189519941a971b961c911d901e931f9220ad21ac22
      af23ae24a925a826ab27aa28a529a42aa72ba62ca12da02ea32fa230bd31
      bc32bf33be34b935b836bb37ba38b539b43ab73bb63cb13db03eb33fb240
      cd41cc42cf43ce44c945c846cb008e07890e8009871c921b95129c159b38
      b63fb136b831bf24aa23ad2aa42da370fe77f97ef079f76ce26be562ec65
      eb48c64fc146c841cf54da53dd5ad45dd3e06ee769ee60e967fc72fb75f2
      7cf57bd856df51d658d15fc44ac34dca44cd43901e97199e1099178c028b
      05820c850ba826af21a628a12fb43ab33dba34bd33db55dc52d55bd25cc7
      49c04ec947ce008f058a0a850f80149b119e1e911b9428a72da222ad27a8
      3cb339b636b933bc50df55da5ad55fd044cb41ce4ec14bc478f77df272fd
      77f86ce369e666e963eca02fa52aaa25af20b43bb13ebe31bb3488078d02
      820d87089c1399169619931cf07ff57afa75ff70e46be16eee61eb64d857
      dd52d25dd758cc43c946c649c34c5bd45ed151de54db4fc04ac545ca40cf
      00903bab76e64dddec7cd7479a0aa131c353f868b5258e1e2fbf148459c9
      62f29d0da636eb7bd04071e14ada07973cac5ece65f528b81383b2228919
      c454ff6f21b11a8a57c76cfccd5df666bb2b8010e272d9499404af3f0e9e
      35a578e843d3bc2c8717ca5af16150c06bfb26b61d8d7fef44d4099932a2
      9303a838e575de4e42d279e934a40f9fae3e9505d848e37381009139a872
      e34bdae475dd4c9607af3ed342ea7ba130980937a60e9f45d47cedbd2c84
      15cf5ef66759c860f12bba12836eff57c61c8d25b48a1bb322f869c15061
      f058c913822abb8514bc2df766ce5fb2238b1ac051f96856c76ffe24b51d
      8cdc4de574ae3f970638a901904adb73e20f9e36a77dec44d5eb7ad24399
      08a031c253fb6ab021891826b71f8e54c56dfc118000923fad7eec41d3fc
      6ec3518210bd2fe371dc4e9d0fa2301f8d20b261f35eccdd4fe270a3319c
      0e21b31e8c5fcd60f23eac019340d27fedc250fd6fbc2e8311a1339e0cdf
      4de0725dcf62f023b11c8e42d07def3cae0391be2c8113c052ff6d7cee43
      d102903daf8012bf2dfe6cc1539f0da032e173de4c63f15cce1d8f22b059
      cb66f427b5188aa5379a08db49e476ba288500933dae7ae947d4f467c95a
      8e1db320f360ce5d891ab42707943aa97dee40d3fd6ec0538714ba29099a
      34a773e04edd0e9d33a074e749dafa69c7548013bd2ee172dc4f9b08a635
      158628bb6ffc52c112812fbc68fb55c6e675db489c0fa1321c8f21b266f5
      5bc8e87bd5469201af3cef7cd2419506a83b1b8826b561f25ccfd94ae477
      a3309e0d2dbe108357c46af92ab91784009433a766f255c1cc58ff6baa3e
      990d8317b024e571d6424fdb7ce829bd1a8e1d892eba7bef48dcd145e276
      b72384109e0aad39f86ccb5f52c661f534a007933aae099d5cc86ffbf662
      c5519004a337b92d8a1edf4bec7875e146d2138720b427b3148041d572e6
      eb7fd84c8d19be2aa4309703c256f16568fc5bcf0e9a3da974e047d31286
      21b5b82c8b1fde4aed79f763c45091009531a462f753c6c451f560a63397
      029306a237f164c05557c266f335a004913da80c995fca6efbf96cc85d9b
      0eaa3fae3b9f0acc59fd686aff5bce089d39ac7aef4bde188d29bcbe2b8f
      1adc49ed78e97cd84d8b1eba2f2db81c894fda7eeb47d276e325b0148183
      16b227e174d045d441e570b6238712108521b472e743d6f461c5509603a7
      3230a5019452c763f667f256c30590009637a16ef859cfdc4aeb7db22485
      13a3359402cd5bfa6c7fe948de118726b05dcb6afc33a504928117b620ef
      79d84efe68c95f9006a73122b415834cda7bedba2c8d1bd442e37566f051
      c7089e3fa9198f2eb877e140d6c553f264ab3d9c0ae771d046891fbe283b
      ad0c9a55c362f444d273e52abc1d8b980eaf39f660c1576ff958ce019736
      a0b3258412dd4bea7ccc5afb6da23495009735a26afd5fc8d443e176be29
      8b1cb3248611d94eec7b67f052c50d9a38af7dea48df178022b5a93e9c0b
      c354f661ce59fb6ca43391061a8d2fb870e745d2fa6dcf589007a5322eb9
      1b8c44d371e649de7ceb23b416819d0aa83ff760c2558710b225ed7ad84f
      53c466f139ae0c9b34a301965ec96bfce077d5428a1dbf28ef78da4d8512
      b0273bac0e9951c664f35ccb69fe36a1039400982bb356ce7de5ac34871f
      fa62d14943db68f0158d3ea6ef77c45cb921920a861ead35d048fb632ab2
      01997ce457cfc55dee76930bb82069f142da3fa7148c178f3ca441d96af2
      bb239008ed75c65e54cc7fe7029a29b1f860d34bae36851d9109ba22c75f
      ec743da5168e6bf340d8d24af961841caf377ee655cd28b0039b2eb6059d
      78e053cb821aa931d44cff676df546de3ba31088c1009929b052cb7be2a4
      3d8d14f66fdf4653ca7ae3019828b1f76ede47a53c8c15a63f8f16f46ddd
      44029b2bb250c979e0f56cdc45a73e8e1751c878e1039a2ab357ce7ee705
      9c2cb5f36ada43a1388811049d2db456cf7fe6a0398910f26bdb42f168d8
      41a33a8a1355cc7ce5079e2eb7a23b8b12f069d940069f2fb654cd7de4ae
      37871efc65d54c0a9323ba58c171e8fd64d44daf36861f59c0009a2fb55e
      c471ebbc269309e278cd5763f94cd63da71288df45f06a811bae34c65ce9
      739802b72d7ae055cf24be0b91a53f8a10fb61d44e198336ac47dd68f297
      0db822c953e67c2bb1049e75ef5ac0f46edb41aa30851f48d267fd168c39
      a351cb7ee40f9520baed77c258b3299c0632a81d876cf643d98e14a13bd0
      4aff6535af1a806bf144de8913a63cd74df86256cc79e3089227bdea70c5
      009b2db65ac177ecb42f9902ee75c35873e85ec529b2049fc75cea719d06
      b02be67dcb50bc27910a52c97fe4089325be950eb823cf54e27921ba0c97
      7be056cdd74cfa618d16a03b63f84ed539a2148fa43f8912fe65d348108b
      3da64ad167fc31aa1c876bf046dd851ea833df44f26942d96ff4188335ae
      f66ddb40ac37811ab52e9803ef74c259019a2cb75bc076edc65deb709c07
      b12a72e95fc4009c23bf46da65f98c10af33ca56e975039f20bc45d966fa
      8f13ac30c955ea76069a25b940dc63ff8a16a935cc50ef73059926ba43df
      60fc8915aa36cf53ec700c902fb34ad669f5801ca33fc65ae5790f932cb0
      49d56af6831fa03cc559e67a0a9629b54cd06ff3861aa539c05ce37f0995
      2ab64fd36cf08519a63ac35fe07c18843ba75ec27de19408b72bd24ef16d
      1b8738a45dc17ee2970bb428d1009d21bc42df63fe8419a538c65be77a13
      8e32af51cc70ed970ab62bd548f46926bb079a64f945d8a23f831ee07dc1
      5c35a8148977ea56cbb12c900df36ed24f4cd16df00e932fb2c855e9748a
      17ab365fc27ee31d803ca1db46fa679904b8256af74bd628b50994ee73cf
      52ac318d1079e458c53ba61a87fd60dc41bf229e039805b924da47fb661c
      813da05ec37fe28b16aa37c954e8750f922eb34dd0009e27b94ed069f79c
      02bb25d24cf56b23bd049a6df34ad4bf219806f16fd64846d861ff08962f
      b1da44fd63940ab32d65fb42dc2bb50c92f967de40b729900e8c12ab35c2
      5ce57b108e37a95ec079e7af318816e17fc65833ad148a7de35ac4ca54ed
      73841aa33d56c871ef18863fa1e977ce50a739801e75eb52cc3ba51c8203
      9d24ba4dd36af49f01b826d14ff66820be07996ef049d7bc229b05f26cd5
      009f25ba4ad56ff0940bb12ede41fb6433ac168979e65cc3a738821ded72
      c85766f943dc2cb30996f26dd748b8279d0255ca70ef1f803aa5c15ee47b
      8b14ae31cc53e9768619a33c58c77de2128d37a8ff60da45b52a900f6bf4
      4ed121be049baa358f10e07fc55a3ea11b8474eb51ce9906bc23d34cf669
      0d9228b747d862fd831ca639c956ec73178832ad5dc278e7b02f950afa65
      df4024bb019e6ef14bd400a05bfbb616ed4d77d72c8cc1619a3aee4eb515
      58f803a39939c2622f8f74d4c7679c3c71d12a8ab010eb4b06a65dfd2989
      72d29f3fc4645efe05a5e848b3139535ce6e238378d8e242b91954f40faf
      7bdb2080cd6d96360cac57f7ba1ae14152f209a9e444bf1f25857ede9333
      c868bc1ce7470aaa51f1cb6b90307ddd268631916aca8727dc7c46e61dbd
      f050ab0bdf7f842469c93292a808f3531ebe45e5f600a159f8b213eb4a7f
      de2687cd6c9435fe5fa7064ced15b48120d87933926acbe746be1f55f40c
      ad9839c1602a8b73d219b840e1ab0af25366c73f9ed4758d2cd5748c2d67
      c63e9faa0bf35218b941e02b8a72d39938c06154f50dace647bf1e32936b
      ca8021d9784dec14b5ff5ea607cc6d95347edf2786b312ea4b01a058f9b1
      10e84903a25afbce6f97367cdd25844fee16b7fd5ca405309169c88223db
      7a56f700a25ffdbe1ce14367c5389ad97b8624ce6c913370d22f8da90bf6
      5417b548ea8725d87a399b66c4e042bf1d5efc01a349eb16b4f755a80a2e
      8c71d39032cf6d15b74ae8ab09f45672d02d8fcc6e9331db79842665c73a
      98bc1ee34102a05dff9230cd6f2c8e73d1f557aa084be914b65cfe03a1e2
      40bd1f3b9964c68527da782a8875d79436cb694def12b0f351ac0ee446bb
      195af805a78321dc7e3d9f62c0ad0ff200a35dfeba19e7446fcc3291d576
      882bde7d832064c7399ab112ec4f0ba856f5a704fa591dbe40e3c86b9536
      72d12f8c79da2487c3609e3d16b54be8ac0ff15255f608abef4cb2113a99
      67c48023dd7e8b28d67531926ccfe447b91a5efd03a0f251af0c48eb15b6
      9d3ec06327847ad92c8f71d29635cb6843e01ebdf95aa407aa09f75410b3
      4deec566983b7fdc228174d7298ace6d93301bb846e5a102fc5f0dae50f3
      00a453f7a602f55157f304a0f155a206ae0afd5908ac5bfff95daa0e5ffb
      0ca847e314b0e145b21610b443e7b612e541e94dba1e4feb1cb8be1aed49
      18bc4bef8e2add79288c7bdfd97d8a2e7fdb2c88208473d78622d57177d3
      2480d1758226c96d9a3e6fcb3c989e3acd69389c6bcf67c33490c1659236
      309463c79632c56107a354f0a105f25650f403a7f652a501a90dfa5e0fab
      5cf8fe5aad0958fc0baf40e413b7e600a551f4a207f3565ffa0eabfd58ac
      09be1bef4a1cb94de8e144b01543e612b767c23693c5609431389d69cc9a
      3fcb6ed97c882d7bde2a8f8623d772248175d0ce6b9f3a6cc93d989134c0
      65339662c770d52184d27783262f8a7edb8d28dc79a90cf85d0bae5afff6
      53a70254f105a017b246e3b510e44148ed19bcea4fbb1e8722d673258074
      d1d87d892c7adf2b8e399c68cd9b3eca6f66c33792c4619530e045b11442
      e700a657f1ae08f95f47e110b6e94fbe188e28d97f208677d1c96f9e3867
      c1309607a150f6a90ffe5840e617b1ee48b91f892fde78278170d6ce6899
      3f60c637910ea859ffa006f75149ef1eb8e741b0168026d7712e8879dfc7
      61903669cf3e9809af5ef8a701f0564ee819bfe046b7118721d076298f7e
      d8c06697316ec8399f1cba4bedb214e5435bfd0caaf553a2049234c5633c
      9a6bcdd57382247bdd2c8a1bbd4ceab513e200a755f2aa0dff584fe81abd
      e542b0179e39cb6c349361c6d17684237bdc2e89278072d58d2ad87f68cf
      3d9ac2659730b91eec4b13b446e1f651a3045cfb09ae4ee91bbce443b116
      01a654f3ab0cfe59d07785227add2f889f38ca6d359260c769ce3c9bc364
      9631268173d48c2bd97ef750a2055dfa08afb81fed4a12b547e09c3bc96e
      369163c4d374862179de2c8b02a557f0a80ffd5a4dea18bfe740b215bb1c
      ee4911b644e300a84be3963edd75379f7cd4a109ea426ec6258df850b31b
      59f112bacf67842cdc74973f4ae201a9eb43a0087dd5369eb21af951248c
      6fc7852dce6613bb58f0a30be840359d7ed6943cdf7702aa49e1cd65862e
      5bf310b8fa52b1196cc4278f7fd7349ce941a20a48e003abde76953d11b9
      5af2872fcc64268e6dc5b018fb535df516becb6380286ac22189fc54b71f
      339b78d0a50dee4604ac4fe7923ad9718129ca6217bf5cf4b600a949e092
      3bdb723f9676dfad04e44d7ed7379eec45a50c41e808a1d37a9a33fc55b5
      1c6ec7278ec36a8a2351f818b1822bcb6210b959f0bd14f45d2f8666cfe3
      4aaa0371d83891dc75953c4ee707ae9d34d47d0fa646efa20beb42309979
      d01fb656ff8d24c46d208969c0b21bfb5261c82881f35aba135ef717becc
      65852cdd74943d4fe606afe24bab0270d93990a30aea43319878d19c35d5
      7c0ea747ee218868c1b31afa531eb700aa4fe59e34d17b278d68c2b913f6
      5c4ee401abd07a9f3569c3268cf75db8129c36d37902a84de7bb11f45e25
      8f6ac0d2789d374ce603a9f55fba106bc1248e23896cc6bd17f25804ae4b
      e19a30d57f6dc72288f359bc164ae005afd47e9b31bf15f05a218b6ec498
      32d77d06ac49e3f15bbe146fc5208ad67c993348e207ad46ec09a3d87297
      3d61cb2e84ff55b01a08a247ed963cd9732f8560cab11bfe54da70953f44
      ee0ba1fd57b200ab4de69a31d77c2f8462c9b51ef8535ef513b8c46f8922
      71da3c97eb40a60dbc17f15a268d6bc09338de7509a244efe249af0478d3
      359ecd66802b57fc1ab163c82e85f952b41f4ce701aad67d9b303d9670db
      a70cea4112b95ff48823c56edf74923945ee08a3f05bbd166ac1278c812a
      cc671bb056fdae05e348349f79d2c66d8b205cf711bae942a40f73d83e95
      9833d57e02a94fe4b71cfa512d8660cb7ad1379ce04bad0655fe18b300ac
      43ef862ac56917bb54f8913dd27e2e826dc1a804eb4739957ad6bf13fc50
      5cf01fb3da7699354be708a4cd618e2272de319df458b71b65c9268ae34f
      a00cb814fb573e927dd1af03ec4029856ac6963ad57910bc53ff812dc26e
      07ab44e8e448a70b62ce218df35fb01c75d9369aca6689254ce00fa3dd71
      9e325bf718b46bc72884ed41ae027cd03f93fa56b91545e906aac36f802c
      52fe11bdd478973b379b74d8b11df25e208c63cfa600ad41ec822fc36e1f
      b25ef39d30dc713e937fd2bc11fd50218c60cda30ee24f7cd13d90fe53bf
      1263ce228fe14ca00d42ef03aec06d812c5df01cb1df729e33f855b9147a
      d73b96e74aa60b65c82489c66b872a44e905a8d97498355bf61ab78429c5
      6806ab47ea9b36da7719b458f5ba17fb56389579d4a508e449278a66cbeb
      46aa0769c42885f459b51876db379ad578943957fa16bbca678b2648e509
      a4973ad67b15b854f98825c9640aa700ae47e98e20c96707a940ee8927ce
      600ea049e7802ec76909a74ee08729c06e1cb25bf5923cd57b1bb55cf295
      3bd27c12bc55fb9c32db7515bb52fc9b35dc7238967fd1b618f15f3f9178
      d6b11ff658369871dfb816ff51319f76d8bf11f856248a63cdaa04ed4323
      8d64caad03ea442a846dc3a40ae34d2d836ac4a30de44a70de3799fe50b9
      1777d9309ef957be107ed03997f05eb71979d73e90f759b01e6cc22b85e2
      4ca50b6bc52c82e54ba200af45ea8a25cf600fa04ae5852ac06f1eb15bf4
      943bd17e11be54fb9b34de713c9379d6b619f35c339c76d9b916fc53228d
      67c8a807ed422d8268c7a708e24d78d73d92f25db71877d8329dfd52b817
      66c9238cec43a90669c62c83e34ca60944eb01aece618b244be40ea1c16e
      842b5af51fb0d07f953a55fa10bfdf709a35f05fb51a7ad53f90ff50ba15
      75da309fee41ab0464cb218ee14ea40b6bc42e81cc63892646e903acc36c
      862949e60ca300b07bcbf6468d3df7478c3c01b17acaf5458e3e03b378c8
      02b279c9f4448f3ff1418a3a07b77ccc06b67dcdf0408b3b04b47fcff242
      8939f343883805b57ecef94982320fbf74c40ebe75c5f84883330cbc77c7
      fa4a8131fb4b80300dbd76c608b873c3fe4e8535ff4f843409b972c2fd4d
      86360bbb70c00aba71c1fc4c8737e95992221faf64d41eae65d5e8589323
      1cac67d7ea5a9121eb5b90201dad66d618a863d3ee5e9525ef5f942419a9
      62d2ed00b179c8f2438b3aff4e86370dbc74c5e5549c2d17a66edf1aab63
      d2e8599120d160a81923925aeb2e9f57e6dc6da51434854dfcc677bf0ecb
      7ab203398840f1b908c0714bfa328346f73f8eb405cd7c5ced2594ae1fd7
      66a312da6b51e0289968d911a09a2be3529726ee5f65d41cad8d3cf4457f
      ce06b772c30bba8031f94869d810a19b2ae2539627ef5e64d51dac8c3df5
      447ecf07b673c20abb8130f849b809c1704afb338247f63e8fb504cc7d5d
      ec00b27fcdfe4c8133e755982a19ab66d4d567aa182b9954e632804dffcc
      7eb301b103ce7c4ffd308256e4299ba81ad76564d61ba99a28e5578331fc
      4e7dcf02b079cb06b48735f84a9e2ce15360d21fadac1ed36152e02d9f4b
      f93486b507ca78c87ab705368449fb2f9d50e2d163ae1c1daf62d0e3519c
      2efa48853704b67bc9f2408d3f0cbe73c115a76ad8eb599426279558ead9
      6ba614c072bf0d3e8c41f343f13c8ebd0fc270a416db695ae825979624e9
      00b37dcefa498734ef5c922115a668dbc576b80b3f8c42f12a9957e4d063
      ad1e9122ec5f6bd816a57ecd03b08437f94a54e7299aae1dd360bb08c675
      41f23c8f398a44f7c370be0dd665ab182c9f51e2fc4f813206b57bc813a0
      6edde95a9427a81bd56652e12f9c47f43a89bd0ec0736dde10a39724ea59
      8231ff4c78cb05b672c10fbc883bf5469d2ee05367d41aa9b704ca794dfe
      308358eb2596a211df6ce3509e2d19aa64d70cbf71c2f6458b3826955be8
      00b473c7e6529521d763a410318542f6b501c67253e7209462d611a58430
      f74371c502b69723e450a612d56140f43387c470b703229651e513a760d4
      f5418632e256912504b077c3358146f2d367a01457e32490b105c2768034
      f34766d215a19327e05475c106b244f03783a216d165269255e1c074b307
      f145823617a364d0df6bac18398d4afe08bc7bcfee5a9d296ade19ad8c38
      ff4bbd09ce7a5bef289cae1add6948fc3b8f79cd0abe9f2bec581baf68dc
      fd00b571c4e2579326df6aae1b3d884cf9a510d46147f236837acf0bbe98
      2de95c51e42095b306c2778e3bff4a6cd91da8f441853016a367d22b9e5a
      efc97cb80da217d36640f531847dc80cb99f2aee5b07b276c3e5509421d8
      6da91c3a8f4bfef346823711a460d52c995de8ce7bbf0a56e32792b401c5
      70893cf84d6bde1aaf5fea2e9bbd08cc798035f14462d713a6fa4f8b3e18
      ad69dc259054e1c772b6030ebb7fcaec599d28d164a015338642f7ab1eda
      6f49fc00b677c1ee58992fc771b006299f5ee89523e2547bcd0cba52e425
      93bc0acb7d318746f0df69a81ef640813718ae6fd9a412d3654afc3d8b63
      d514a28d3bfa4c62d415a38c3afb4da513d2644bfd3c8af741803619af6e
      d8308647f1de68a91f53e52492bd0bca7c9422e3557acc0dbbc670b10728
      9e5fe901b776c0ef59982ec472b3052a9c5deb03b574c2ed5b9a2c51e726
      90bf09c87e9620e15778ce0fb9f54382341bad6cda328445f3dc6aab1d60
      d617a18e38f900b775c2ea5d9f28cf78ba0d259250e78532f0476fd81aad
      4afd3f88a017d56211a664d3fb4c8e39de69ab1c348341f69423e1567ec9
      0bbc5bec2e99b106c473229557e0c87fbd0aed5a982f07b072c5a710d265
      4dfa388f68df1daa8235f740338446f1d96eac1bfc4b893e16a163d4b601
      c3745ceb299e79ce0cbb9324e65144f33186ae19db6c8b3cfe4961d614a3
      c176b4032b9c5ee90eb97bcce453912655e22097bf08ca7d9a2def5870c7
      05b2d067a5123a8d4ff800b86bd3d66ebd05b70fdc6461d90ab275cd1ea6
      a31bc870c27aa91114ac7fc7ea5281393c8457ef5de5368e8b33e0589f27
      f44c49f1229a289043fbfe46952dcf77a41c19a172ca78c013abae16c57d
      ba02d1696cd407bf0db566dedb63b008259d4ef6f34b9820922af94144fc
      2f9750e83b83863eed55e75f8c3431895ae2853dee5653eb3880328a59e1
      e45c8f37f0489b23269e4df547ff2c949129fa426fd704bcb901d26ad860
      b30b0eb665dd1aa271c9cc74a71fad00b969d0d26bbb02bf06d66f6dd404
      bd65dc0cb5b70ede67da63b30a08b161d8ca73a31a18a171c875cc1ca5a7
      1ece77af16c67f7dc414ad10a979c0c27bab128f36e65f5de4348d308959
      e0e25b8b32ea53833a388151e855ec3c85873eee5745fc2c95972efe47fa
      43932a289141f8209949f0f24b9b229f26f64f4df4249d05bc6cd5d76ebe
      07ba03d36a68d101b860d909b0b20bdb62df66b60f0db464ddcf76a61f1d
      a474cd70c919a0a21bcb72aa13c37a78c111a815ac00ba6fd5de64b10ba7
      1dc87279c316ac55ef3a808b31e45ef2489d272c9643f9aa10c57f74ce1b
      a10db762d8d369bc06ff45902a219b4ef458e2378d863ce9534ff5209a91
      2bfe44e852873d368c59e31aa075cfc47eab11bd07d26863d90cb6e55f8a
      303b8154ee42f82d979c26f349b00adf656ed401bb17ad78c2c973a61c9e
      24f14b40fa2f95398356ece75d8832cb71a41e15af7ac06cd603b9b208dd
      67348e5be1ea50853f9329fc464df7229861db0eb4bf05d06ac67ca900bb
      6dd6da61b70caf14c27975ce18a345fe28939f24f249ea51873c308b5de6
      8a31e75c50eb3d86259e48f3ff449229cf74a21915ae78c360db0db6ba01
      d76c0fb462d9d56eb803a01bcd767ac117ac4af1279c902bfd46e55e8833
      3f8452e9853ee8535fe432892a9147fcf04b9d26c07bad161aa177cc6fd4
      02b9b50ed8631ea573c8c47fa912b10adc676bd006bd5be0368d813aec57
      f44f99222e9543f8942ff9424ef523983b8056ede15a8c37d16abc070bb0
      66dd7ec513a800bc63dfc67aa519972bf44851ed328e358956eaf34f902c
      a21ec17d64d807bb6ad609b5ac10cf73fd419e223b8758e45fe33c809925
      fa46c874ab170eb26dd1d468b70b12ae71cd43ff209c8539e65ae15d823e
      279b44f876ca15a9b00cd36fbe02dd6178c41ba729954af6ef538c308b37
      e8544df12e921ca07fc3da66b905b30fd06c75c916aa249847fbe25e813d
      863ae55940fc239f11ad72ced76bb408d965ba061fa37cc04ef22d918834
      eb57ec508f332a9649f57bc718a4bd00bd61dcc27fa31e9f22fe435de03c
      81259844f9e75a863bba07db6678c519a44af72b968835e954d568b40917
      aa76cb6fd20eb3ad10cc71f04d912c328f53ee9429f54856eb378a0bb66a
      d7c974a815b10cd06d73ce12af2e934ff2ec518d30de63bf021ca17dc041
      fc209d833ee25ffb469a27398458e564d905b8a61bc77a338e52eff14c90
      2dac11cd706ed30fb216ab77cad469b5088934e8554bf62a9779c418a5bb
      06da67e65b873a249945f85ce13d809e23ff42c37ea21f01bc00be67d9ce
      70a9178739e05e49f72e9015ab72ccdb65bc02922cf54b5ce23b852a944d
      f3e45a833dad13ca7463dd04ba3f8158e6f14f9628b806df6176c811af54
      ea338d9a24fd43d36db40a1da37ac441ff26988f31e856c678a11f08b66f
      d17ec019a7b00ed769f9479e20378950ee6bd50cb2a51bc27cec528b3522
      9c45fba816cf7166d801bf2f9148f6e15f8638bd03da6473cd14aa3a845d
      e3f44a932d823ce55b4cf22b9505bb62dccb75ac129729f04e59e73e8010
      ae77c9de60b900bf65daca75af108f30ea5545fa209f05ba60dfcf70aa15
      8a35ef5040ff259a0ab56fd0c07fa51a853ae05f4ff02a950fb06ad5c57a
      a01f803fe55a4af52f9014ab71cede61bb049b24fe4151ee348b11ae74cb
      db64be019e21fb4454eb318e1ea17bc4d46bb10e912ef44b5be43e811ba4
      7ec1d16eb40b942bf14e5ee13b8428974df2e25d8738a718c27d6dd208b7
      2d9248f7e758823da21dc77868d70db2229d47f8e8578d32ad12c87767d8
      02bd279842fded528837a817cd7262dd07b800c09b5b2dedb6765a9ac101
      77b7ec2cb4742fef995902c2ee2e75b5c303589873b3e8285e9ec50529e9
      b27204c49f5fc7075c9cea2a71b19d5d06c6b0702bebe6267dbdcb0b5090
      bc7c27e791510aca5292c9097fbfe42408c8935325e5be7e95550eceb878
      23e3cf0f5494e22279b921e1ba7a0ccc97577bbbe0205696cd0dd7174c8c
      fa3a61a18d4d16d6a0603bfb63a3f8384e8ed51539f9a26214d48f4fa464
      3fff894912d2fe3e65a5d313488810d08b4b3dfda6664a8ad11167a7fc3c
      3100c1995829e8b0715293cb0a7bbae223a4653dfc8d4c14d5f6376faedf
      1e46875392ca0b7abbe32201c0985928e9b170f7366eafde1f4786a5643c
      fd8c4d15d4a6673ffe8f4e16d7f4356dacdd1c448502c39b5a2beab27350
      91c90879b8e021f5346caddc1d4584a7663eff8e4f17d65190c80978b9e1
      2003c29a5b2aebb3725796ce0f7ebfe72605c49c5d2cedb574f3326aabda
      1b4382a16038f9884911d004c59d5c2decb4755697cf0e7fbee627a06139
      f8894810d1f2336baadb1a4283f13000c29f5d25e7ba784a88d5176fadf0
      3294560bc9b1732eecde1c4183fb3964a633f1ac6e16d4894b79bbe6245c
      9ec301a76538fa82401ddfed2f72b0c80a579566a4f93b4381dc1e2ceeb3
      7109cb9654f2306dafd715488ab87a27e59d5f02c05597ca0870b2ef2d1f
      dd80423af8a567c1035e9ce4267bb98b4914d6ae6c31f3cc0e5391e92b76
      b4864419dba3613cfe589ac7057dbfe22012d08d4f37f5a86aff3d60a2da
      184587b5772ae890520fcd6ba9f4364e8cd11321e3be7c04c69b59aa6835
      00c39d5e21e2bc7f4281df1c63a0fe3d844719daa56638fbc6055b98e724
      7ab913d08e4d32f1af6c5192cc0f70b3ed2e97540ac9b6752be8d516488b
      f43769aa26e5bb7807c49a5964a7f93a4586d81ba2613ffc83401edde023
      7dbec1025c9f35f6a86b14d7894a77b4ea295695cb08b1722cef90530dce
      f3306eadd2114f8c4c8fd1126daef0330ecd93502fecb271c80b5596e92a
      74b78a4917d4ab6836f55f9cc2017ebde3201dde80433cffa162db184685
      fa3967a4995a04c7b87b25e66aa9f73400c493573df9ae6a7abee92d4783
      d410f43067a3c90d5a9e8e4a1dd9b37720e4f33760a4ce0a5d99894d1ade
      b47027e307c394503afea96d7db9ee2a4084d317fd396eaac00453978743
      14d0ba7e29ed09cd9a5e34f0a76373b7e0244e8add190eca9d5933f7a064
      74b0e723498dda1efa3e69adc7035490804413d7bd792eeae12572b6dc18
      4f8b9b5f08cca66235f115d1864228ecbb7f6fabfc385296c10512d68145
      2febbc7868acfb3f5591c602e62275b1db1f488c9c580fcba16532f61cd8
      8f4b2100c5915439fca86d72b7e3264b8eda1fe42175b0dd184c89965307
      c2af6a3efbd3164287ea2f7bbea16430f5985d09cc37f2a6630ecb9f5a45
      80d4117cb9ed28bd782ce9844115d0cf0a5e9bf63367a2599cc80d60a5f1
      342beeba7f12d783466eabff3a5792c6031cd98d4825e0b4718a4f1bdeb3
      7622e7f83d69acc104509561a4f035589dc90c13d682472aefbb7e854014
      d1bc792de8f73266a3ce0b5f9ab27723e68b4e1adfc0055194f93c68ad56
      93c7026faafe3b24e1b5701dd88c49dc194d88e52000c6975135f3a2646a
      acfd3b5f99c80ed4124385e12776b0be7829ef8b4d1cdab37524e2864011
      d7d91f4e88ec2a7bbd67a1f0365294c5030dcb9a5c38feaf697dbbea2c48
      8edf1917d1804622e4b573a96f3ef89c5a0bcdc3055492f63061a7ce0859
      9ffb3d6caaa46233f5915706c01adc8d4b2fe9b87e70b6e7214583d214fa
      3c6dabcf09589e905607c1a56332f42ee8b97f1bdd8c4a4482d31571b7e6
      20498fde187cbaeb2d23e5b47216d081479d5b0acca86e3ff9f73160a6c2
      045593874110d6b2742500c7955231f6a46362a5f7305394c601c4035196
      f53260a7a66133f4975002c5935406c1a26537f0f13664a3c00755925790
      c20566a1f33435f2a06704c391563dfaa86f0ccb995e5f98ca0d6ea9fb3c
      f93e6cabc80f5d9a9b5c0ec9aa6d3ff8ae693bfc9f580acdcc0b599efd3a
      68af6aadff385b9cce0908cf9d5a39feac6b7abdef284b8cde1918df8d4a
      29eebc7bbe792bec8f481adddc1b498eed2a78bfe92e7cbbd81f4d8a8b4c
      1ed9ba7d2fe82deab87f1cdb894e4f88da1d7eb9eb2c4780d21576b1e324
      00c88b430dc5864e1ad2915917df9c5434fcbf7739f1b27a2ee6a56d23eb
      a86068a0e32b65adee2672baf9317fb7f43c5c94d71f5199da12468ecd05
      4b83c008d0185b93dd15569eca024189c70f4c84e42c6fa7e92162aafe36
      75bdf33b78b0b87033fbb57d3ef6a26a29e1af6724ec8c4407cf81490ac2
      965e1dd59b5310d8bb7330f8b67e3df5a1692ae2ac6427ef8f4704cc824a
      09c1955d1ed6985013dbd31b5890de16559dc901428ac40c4f87e72f6ca4
      ea2261a9fd3576bef0387bb36ba3e02866aeed257100c9894009c0804912
      db9b521bd2925b24edad642de4a46d36ffbf763ff6b67f4881c1084188c8
      015a93d31a539ada136ca5e52c65acec257eb7f73e77befe37905919d099
      5010d9824b0bc28b4202cbb47d3df4bd7434fda66f2fe6af6626efd81151
      98d1185891ca03438ac30a4a83fc3575bcf53c7cb5ee2767aee72e6ea73b
      f2b27b32fbbb7229e0a06920e9a9601fd6965f16df9f560dc4844d04cd8d
      4473bafa337ab3f33a61a8e82168a1e128579ede175e97d71e458ccc054c
      85c50cab6222eba26b2be2b97000ca8f4505cf8a400ac0854f0fc5804a14
      de9b5111db9e541ed4915b1bd1945e28e2a76d2de7a26822e8ad6727eda8
      623cf6b37939f3b67c36fcb97333f9bc76509adf15559fda105a90d51f5f
      95d01a448ecb01418bce044e84c10b4b81c40e78b2f73d7db7f23872b8fd
      3777bdf8326ca6e32969a3e62c66ace92363a9ec26a06a2fe5a56f2ae0aa
      6025efaf6520eab47e3bf1b17b3ef4be7431fbbb7134fe884207cd8d4702
      c882480dc7874d08c29c5613d9995316dc965c19d393591cd6f03a7fb5f5
      3f7ab0fa307500cb8d4601ca8c4702c98f4403c88e4504cf894205ce8843
      06cd8b4007cc8a4108c3854e09c2844f0ac1874c0bc0864d0cc7814a0dc6
      804b0ec583480fc4824910db9d5611da9c5712d99f5413d89e5514df9952
      15de985316dd9b5017dc9a5118d3955e19d2945f1ad1975c1bd0965d1cd7
      915a1dd6905b1ed593581fd4925920ebad6621eaac6722e9af6423e8ae65
      24efa96225eea86326edab6027ecaa6128e3a56e29e2a46f2ae1a76c2be0
      a66d2ce7a16a2de6a06b2ee5a3682fe4a26930fbbd7631fabc7732f9bf74
      00cc834f1dd19e523af6b97527eba46874b8f73b69a5ea264e82cd01539f
      d01ce8246ba7f53976bad21e519dcf034c809c501fd3814d02cea66a25e9
      bb7738f4cb074884d61a5599f13d72beec206fa3bf733cf0a26e21ed8549
      06ca98541bd723efa06c3ef2bd7119d59a5604c8874b579bd4184a86c905
      6da1ee2270bcf33f8d410ec2905c13dfb77b34f8aa6629e5f9357ab6e428
      67abc30f408cde125d9165a9e62a78b4fb375f93dc10428ec10d11dd925e
      0cc08f432be7a86436fab579468ac5095b97d8147cb0ff336100cd814c19
      d4985532ffb37e2be6aa6764a9e5287db0fc31569bd71a4f82ce03c80549
      84d11c509dfa377bb6e32e62afac612de0b57834f99e531fd2874a06cb8b
      460ac7925f13deb97438f5a06d21ecef226ea3f63b77badd105c91c40945
      88438ec20f5a97db1671bcf03d68a5e92427eaa66b3ef3bf7215d894590c
      c18d400dc08c4114d995583ff2be7326eba76a69a4e82570bdf13c5b96da
      17428fc30ec5084489dc115d90f73a76bbee236fa2a16c20edb87539f493
      5e12df8a470bc6864b07ca9f521ed3b47935f8ad6000ce874915db925c2a
      e4ad633ff1b876549ad31d418fc6087eb0f9376ba5ec22a8662fe1bd733a
      f4824c05cb975910defc327bb5e9276ea0d618519fc30d448a4b85cc025e
      90d91761afe62874baf33d1fd198560ac48d4335fbb27c20eea769e32d64
      aaf63871bfc9074e80dc125b95b77930fea26c25eb9d531ad488460fc196
      5811df834d04cabc723bf5a9672ee0c20c458bd719509ee8266fa1fd337a
      b43ef0b9772be5ac6214da935d01cf86486aa4ed237fb1f836408ec70955
      9bd21cdd135a94c8064f81f73970bee22c6500cf854a11de945b22eda768
      33fcb679448bc10e559ad01f66a9e32c77b8f23d88470dc299561cd3aa65
      2fe0bb743ef1cc034986dd125897ee216ba4ff307ab50bc48e411ad59f50
      29e6ac6338f7bd724f80ca055e91db146da2e8277cb3f936834c06c9925d
      17d8a16e24ebb07f35fac708428dd619539ce52a60aff43b71be16d9935c
      07c8824d34fbb17e25eaa06f529dd718438cc60970bff53a61aee42b9e51
      1bd48f400ac5bc7339f6ad6228e7da155f90cb044e81f8377db2e9266ca3
      1dd298570cc389463ff0ba752ee1ab6400d0bb6b6dbdd606da0a61b1b767
      0cdcaf7f14c4c21279a975a5ce1e18c8a3734595fe2e28f893439f4f24f4
      f2224999ea3a518187573cec30e08b5b5d8de6368a5a31e1e7375c8c5080
      eb3b3ded865625f59e4e4898f323ff2f4494924229f9cf1f74a4a27219c9
      15c5ae7e78a8c31360b0db0b0dddb666ba6a01d1d7076cbc0fdfb46462b2
      d909d5056ebeb86803d3a0701bcbcd1d76a67aaac11117c7ac7c4a9af121
      27f79c4c90402bfbfd2d4696e5355e8e885833e33fef84545282e9398555
      3eeee83853835f8fe43432e289592a00d1b96869b8d001d2036bbabb6a02
      d3bf6e06d7d6076fbe6dbcd40504d5bd6c65b4dc0d0cddb564b7660edfde
      0f67b6da0b63b2b3620adb08d9b16061b0d809ca1b73a2a3721acb18c9a1
      7071a0c81975a4cc1d1ccda574a7761ecfce1f77a6af7e16c7c6177fae7d
      acc41514c5ad7c10c1a97879a8c011c2137baaab7a12c38f5e36e7e6375f
      8e5d8ce43534e58d5c30e189585988e031e2335b8a8b5a32e3ea3b538283
      523aeb38e981505180e8395584ec3d3ced855487563eefee3f57864594fc
      2d2cfd954497462efffe2f4796fa2b00d2bf6d65b7da08ca1875a7af7d10
      c28f5d30e2ea3855874597fa2820f29f4d05d7ba6860b2df0dcf1d70a2aa
      7815c78a5835e7ef3d50824092ff2d25f79a480ad8b5676fbdd002c0127f
      ada5771ac885573ae8e0325f8d4f9df0222af895470fddb0626ab8d507c5
      177aa8a0721fcd80523fede5375a884a98f5272ffd904214c6ab7971a3ce
      1cde0c61b3bb6904d69b4924f6fe2c41935183ee3c34e68b5911c3ae7c74
      a6cb19db0964b6be6c01d39e4c21f3fb2944965486eb3931e38e5c1ecca1
      737ba9c416d4066bb9b1630edc91432e00d3bd6e61b2dc0fc2117faca370
      1ecd9f4c22f1fe2d43905d8ee0333cef815225f6984b4497f92ae7345a89
      86553be8ba6907d4db0866b578abc51619caa4774a99f7242bf89645885b
      35e6e93a5487d50668bbb46709da17c4aa7976a5cb186fbcd2010eddb360
      ad7e10c3cc1f71a2f0234d9e91422cff32e18f5c5380ee3d944729faf526
      489b5685eb3837e48a590bd8b6656ab9d704c91a74a7a87b15c6b1620cdf
      d0036dbe73a0ce1d12c1af7c2efd93404f9cf221ec3f51828d5e30e3de0d
      63b0bf6c02d11ccfa1727daec0134192fc2f00d4b3677da9ce1afa2e499d
      875334e0ef3b5c88924621f515c1a67268bcdb0fc51176a2b86c0bdf3feb
      8c584296f1252afe994d5783e430d00463b7ad791eca914522f6ec385f8b
      6bbfd80c16c2a5717eaacd1903d7b064845037e3f92d4a9e5480e73329fd
      9a4eae7a1dc9d30760b4bb6f08dcc61275a14195f2263ce88f5b39ed8a5e
      4490f723c31770a4be6a0dd9d60265b1ab7f18cc2cf89f4b5185e236fc28
      4f9b815532e606d2b5617bafc81c13c7a0746ebadd09e93d5a8e944027f3
      a87c1bcfd50166b25286e1352ffb9c484793f4203a00d5b16479acc81df2
      2743968b5e3aefff2a4e9b865337e20dd8bc6974a1c510e53054819c492d
      f817c2a6736ebbdf0a1acfab7e63b6d207e83d598c914420f5d10460b5a8
      7d19cc23f692475a8feb3e2efb9f4a5782e633dc096db8a57014c134e185
      504d98fc29c61377a2bf6a0edbcb1e7aafb26703d639ec885d4095f124b9
      6c08ddc01571a44b9efa2f32e783564693f7223fea8e5bb46105d0cd187c
      a95c89ed3825f09441ae7b1fcad70266b3a37612c7da0f6bbe5184e03528
      fd994c68bdd90c11c4a0759a4f2bfee3365287974226f3ee3b00d6b76175
      a3c214ea3c5d8b9f4928fecf1978aeba6c0ddb25f392445086e731855332
      e4f02647916fb9d80e1accad7b4a9cfd2b3fe9885ea07617c1d50362b411
      c7a67064b2d305fb2d4c9a8e5839efde0869bfab7d1cca34e283554197f6
      20944223f5e13756807ea8c91f0bddbc6a5b8dec3a2ef8994fb16706d0c4
      1273a522f495435781e036c81e7fa9bd6b0adced3b5a8c984e2ff907d1b0
      6672a4c513a77110c6d20465b34d9bfa2c38ee8f5968bedf091dcbaa7c82
      5435e3f721409633e584524690f127d90f6eb8ac7a1bcdfc2a4b9d895f3e
      00d7b56271a6c413e2355780934426f1df086abdae791bcc3dea885f4c9b
      f92ea57210c7d40361b64790f22536e183547aadcf180bdcbe69984f2dfa
      e93e5c8b5186e43320f79542b36406d1c21577a08e593becff284a9d6cbb
      d90e1dcaa87ff4234196855230e716c1a37467b0d2052bfc9e495a8def38
      c91e7cabb86f0ddaa27517c0d30466b14097f52231e684537daac81f0cdb
      b96e9f482afdee395b8c07d0b26576a1c314e5325087944321f6d80f6dba
      a97e1ccb3aed8f584b9cfe29f3244691825537e011c6a47360b7d5022cfb
      994e5d8ae83f00d8ab734d95e63e9a4231e9d70f7ca42ff7845c62bac911
      b56d1ec6f820538b5e86f52d13cbb860c41c6fb7895122fa71a9da023ce4
      974feb334098a67e0dd5bc6417cff1295a8226fe8d556bb3c018934b38e0
      de0675ad09d1a27a449cef37e23a4991af7704dc78a0d30b35ed9e46cd15
      66be80582bf3578ffc241ac2b16963bbc8102ef6855df921528ab46c1fc7
      4c94e73f01d9aa72d60e7da59b4330e83de5964e70a8db03a77f0cd4ea32
      419912cab9615f87f42c885023fbc51d6eb6df0774ac924a39e1459dee36
      08d0a37bf0285b83bd6516ce6a00d9a9704990e039924b3be2db0272ab3f
      e6964f76afdf06ad7404dde43d4d947ea7d70e37ee9e47ec35459ca57c0c
      d54198e83108d1a178d30a7aa39a4333eafc25558cb56c1cc56eb7c71e27
      fe8e57c31a6ab38a5323fa5188f82118c1b168825b2bf2cb1262bb10c9b9
      605980f029bd6414cdf42d5d842ff6865f66bfcf16e33a4a93aa7303da71
      a8d80138e19148dc0575ac954c3ce54e97e73e07deae779d4434edd40d7d
      a40fd6a67f469fef36a27b0bd2eb32429b30e9994079a0d0091fc6b66f56
      8fff268d5424fdc41d6db420f9895069b0c019b26b00daaf75459fea308a
      5025ffcf1560ba0fd5a07a4a90e53f855f2af0c01a6fb51ec4b16b5b81f4
      2e944e3be1d10b7ea411cbbe64548efb219b4134eede0471ab3ce6934979
      a3d60cb66c19c3f3295c8633e99c4676acd903b96316ccfc26538922f88d
      5767bdc812a87207dded3742982df7825868b2c71da77d08d2e2384d9778
      a2d70d3de79248f2285d87b76d18c277add80232e89d47fd275288b86217
      cd66bcc91323f98c56ec364399a97306dc69b3c61c2cf68359e3394c96a6
      7c09d3449eeb3101dbae74ce1461bb8b5124fe4b91e43e0ed4a17bc11b6e
      00dbad76419aec3782592ff4c3186eb51fc4b2695e85f3289d4630ebdc07
      71aa3ee593487fa4d209bc6711cafd26508b21fa8c5760bbcd16a3780ed5
      e2394f947ca7d10a3de6904bfe255388bf6412c963b8ce1522f98f54e13a
      4c97a07b0dd64299ef3403d8ae75c01b6db6815a2cf75d86f02b1cc7b16a
      df0472a99e4533e8f823558eb96214cf7aa1d70c3be0964de73c4a91a67d
      0bd065bec81324ff8952c61d6bb0875c2af1449fe93205dea873d90274af
      984335ee5b80f62d1ac1b76c845f29f2c51e68b306ddab70479cea319b40
      36edda0177ac19c2b46f00dca37f5d81fe22ba6619c5e73b44986fb3cc10
      32ee914dd50976aa88542bf7de027da1835f20fc64b8c71b39e59a46b16d
      12ceec304f930bd7a874568af529a77b04d8fa2659851dc1be62409ce33f
      c8146bb7954936ea72aed10d2ff38c5079a5da0624f8875bc31f60bc9e42
      3de116cab5694b97e834ac700fd3f12d528e5589f62a08d4ab77ef334c90
      b26e11cd3ae6994567bbc418805c23ffdd017ea28b5728f4d60a75a931ed
      924e6cb0cf13e438479bb9651ac65e82fd2103dfa07cf22e518daf730cd0
      4894eb3715c9b66a9d413ee2c01c63bf27fb84587a00dda17c5984f825b2
      6f13ceeb364a977fa2de0326fb875acd106cb1944935e8fe235f82a77a06
      db4c91ed3015c8b469815c20fdd80579a433ee924f6ab7cb16e73a469bbe
      631fc25588f4290cd1ad70984539e4c11c60bd2af78b5673aed20f19c4b8
      65409de13cab760ad7f22f538e66bbc71a3fe29e43d40975a88d502cf1d5
      0874a98c512df067bac61b3ee39f42aa770bd6f32e528f18c5b964419ce0
      3d2bf68a5772afd30e994438e5c01d61bc5489f5280dd0ac71e63b479abf
      621ec332ef934e6bb6ca17805d21fcd90478a54d90ec3114c9b568ff225e
      83a67b00dea779558bf22caa740dd3ff2158864f91e8361ac4bd63e53b42
      9cb06e17c99e4039e7cb156cb234ea934d61bfc618d10f76a8845a23fd7b
      a5dc022ef0895727f9805e72acd50b8d532af4d8067fa168b6cf113de39a
      44c21c65bb974930eeb9671ec0ec324b9513cdb46a4698e13ff628518fa3
      7d04da5c82fb2509d7ae704e90e9371bc5bc62e43a439db16f16c801dfa6
      78548af32dab750cd2fe205987d00e77a9855b22fc7aa4dd032ff188569f
      4138e6ca146db335eb924c60bec71969b7ce103ce29b45c31d64ba964831
      ef26f8815f73add40a8c522bf5d9077e00dfa57a518ef42ba27d07d8f32c
      56895f80fa250ed1ab74fd225887ac7309d6be611bc4ef304a951cc3b966
      4d92e837e13e449bb06f15ca439ce63912cdb76867b8c21d36e9934cc51a
      60bf944b31ee38e79d4269b6cc139a453fe0cb146eb1d9067ca388572df2
      7ba4de012af58f50865923fcd70872ad24fb815e75aad00fce116bb49f40
      3ae56cb3c9163de29847914e34ebc01f65ba33ec964962bdc71870afd50a
      21fe845bd20d77a8835c26f92ff08a557ea1db048d5228f7dc0379a6a976
      0cd3f8275d820bd4ae715a85ff20f629538ca77802dd548bf12e05daa07f
      00e0db3bad4d769641a19a7aec0c37d7826259b92fcff414c32318f86e8e
      b5551fffc424b25269895ebe8565f31328c89d7d46a630d0eb0bdc3c07e7
      7191aa4a3edee505937348a87f9fa444d23209e9bc5c678711f1ca2afd1d
      26c650b08b6b21c1fa1a8c6c57b76080bb5bcd2d16f6a34378980eeed535
      e20239d94faf94747c9ca747d1310aea3ddde60690704babfe1e25c553b3
      8868bf5f648412f2c9296383b858ce2e15f522c2f9198f6f54b4e1013ada
      4cac9777a0407b9b0dedd63642a29979ef0f34d403e3d838ae4e7595c020
      1bfb6d8db65681615aba2cccf7175d00e1d938a948709149a89071e00139
      d892734baa3bdae203db3a02e37293ab4a3fdee60796774fae7697af4edf
      3e06e7ad4c749504e5dd3ce4053ddc4dac94757e9fa746d7360eef37d6ee
      0f9e7f47a6ec0d35d445a49c7da5447c9d0cedd53441a09879e80931d008
      e9d130a1407899d3320aeb7a9ba3429a7b43a233d2ea0bfc1d25c455b48c
      6db5546c8d1cfdc5246e8fb756c7261eff27c6fe1f8e6f57b6c3221afb6a
      8bb3528a6b53b223c2fa1b51b08869f81921c018f9c120b150688982635b
      ba2bcaf213cb2a12f36283bb5a10f1c928b958608159b88061f01129c8bd
      5c00e2df3da5477a9851b38e6cf4162bc9a2407d9f07e5d83af3112cce56
      b4896b5fbd8062fa1825c70eecd133ab497496fd1f22c058ba8765ac4e73
      9109ebd634be5c61831bf9c426ef0d30d24aa895771cfec321b95b66844d
      af9270e80a37d5e1033edc44a69b79b0526f8d15f7ca2843a19c7ee60439
      db12f0cd2fb755688a6785b85ac2201dff36d4e90b93714caec5271af860
      82bf5d94764ba931d3ee0c38dae7059d7f42a0698bb654cc2e13f19a7845
      a73fdde002cb2914f66e8cb153d93b06e47c9ea341886a57b52dcff2107b
      99a446de3c01e32ac8f5178f6d50b286645900e3dd3ea1427c9f59ba8467
      f81b25c6b2516f8c13f0ce2deb0836d54aa997747f9ca241de3d03e026c5
      fb1887645ab9cd2e10f36c8fb152947749aa35d6e80bfe1d23c05fbc8261
      a7447a9906e5db384caf9172ed0e30d315f6c82bb457698a81625cbf20c3
      fd1ed83b05e6799aa44733d0ee0d92714fac6a89b754cb2816f5e7043ad9
      46a59b78be5d63801ffcc22155b6886bf41729ca0cefd132ad4e7093987b
      45a639dae407c1221cff6083bd5e2ac9f7148b6856b57390ae4dd2310fec
      19fac427b85b658640a39d7ee1023cdfab4876950ae9d734f2112fcc53b0
      8e6d6685bb5800e4d337bd596e8a6185b256dc380febc22611f57f9bac48
      a34770941efacd299f7b4ca822c6f115fe1a2dc943a790745db98e6ae004
      33d73cd8ef0b816552b625c1f612987c4baf44a09773f91d2acee70334d0
      5abe896d866255b13bdfe80cba5e698d07e3d430db3f08ec6682b551789c
      ab4fc52116f219fdca2ea44077934aae997df71324c02bcff81c967245a1
      886c5bbf35d1e602e90d3ade54b08763d53106e2688cbb5fb450678309ed
      da3e17f3c420aa4e799d7692a541cb2f18fc6f8bbc58d23601e50eeadd39
      b3576084ad497e9a10f4c327cc281ffb7195a246f01423c74d00e5d134b9
      5c688d698cb85dd03501e4d23703e66b8eba5fbb5e6a8f02e7d336bf5a6e
      8b06e3d732d63307e26f8abe5b6d88bc59d43105e004e1d530bd586c8965
      80b451dc390de80ce9dd38b5506481b75266830eebdf3ade3b0fea6782b6
      53da3f0bee6386b257b35662870aefdb3e08edd93cb15460856184b055d8
      3d09ecca2f1bfe7396a247a34672971affcb2e18fdc92ca14470957194a0
      45c82d19fc7590a441cc291df81cf9cd28a5407491a74276931efbcf2ace
      2b1ffa7792a643af4a7e9b16f3c722c62317f27f9aae4b7d98ac49c42115
      f014f1c520ad487c9910f5c124a94c00e6d731b55362847197a640c42213
      f5e20435d357b18066937544a226c0f117df3908ee6a8cbd5bae48799f1b
      fdcc2a3ddbea0c886e5fb94caa9b7df91f2ec8a543729410f6c721d43203
      e56187b65047a19076f21425c336d0e107836554b27a9cad4bcf2918fe0b
      eddc3abe58698f987e4fa92dcbfa1ce90f3ed85cba8b6d51b78660e40233
      d520c6f711957342a4b355648206e0d137c22415f37791a0468e6859bf3b
      ddec0aff1928ce4aac9d7b6c8abb5dd93f0ee81dfbca2ca84e7f99f41223
      c541a79670856352b430d6e70116f0c127a34574926781b056d23405e32b
      cdfc1a9e784900e7d532b1566483799eac4bc82f1dfaf21527c043a49671
      8b6c5eb93addef08ff182acd4ea99b7c866153b437d0e2050dead83fbc5b
      698e7493a146c52210f7e50230d754b381669c7b49ae2dcaf81f17f0c225
      a64173946e89bb5cdf380aed1afdcf28ab4c7e996384b651d23507e0e80f
      3dda59be8c6b917644a320c7f512d13604e36087b552a84f7d9a19fecc2b
      23c4f611927547a05abd8f68eb0c3ed92ec9fb1c9f784aad57b08265e601
      33d4dc3b09ee6d8ab85fa542709714f3c12634d3e106856250b74daa987f
      fc1b29cec62113f47790a245bf586a8d0ee9db3ccb2c1ef97a9daf4800e8
      cb238d6546ae01e9ca228c6447af02eac9218f6744ac03ebc8208e6645ad
      04eccf27896142aa05edce26886043ab06eecd258b6340a807efcc248a62
      41a908e0c32b856d4ea609e1c22a846c4fa70ae2c129876f4ca40be3c028
      866e4da50ce4c72f81694aa20de5c62e80684ba30ee6c52d836b48a00fe7
      c42c826a49a110f8db339d7556be11f9da329c7457bf12fad9319f7754bc
      13fbd8309e7655bd14fcdf37997152ba15fdde36987053bb16fedd359b73
      50b817ffdc349a7251b918f0d33b957d5eb619f1d23a947c5fb71af2d139
      977f5cb41bf3d038967e5db51cf4d73f91795ab21d00e9c920896040a909
      e0c029806949a012fbdb329b7252bb1bf2d23b927b5bb224cded04ad4464
      8d2dc4e40da44d6d8436dfff16bf56769f3fd6f61fb65f7f9648a18168c1
      2808e141a88861c82101e85ab3937ad33a1af353ba9a73da3313fa6c85a5
      4ce50c2cc5658cac45ec0525cc7e97b75ef71e3ed7779ebe57fe1737de90
      7959b019f0d039997050b910f9d930826b4ba20be2c22b8b6242ab02ebcb
      22b45d7d943dd4f41dbd54749d34ddfd14a64f6f862fc6e60faf46668f26
      cfef06d83111f851b89871d13818f158b19178ca2303ea43aa8a63c32a0a
      e34aa3836afc1535dc759cbc55f51c00eacf25856f4aa011fbde34947e5b
      b122c8ed07a74d688233d9fc16b65c799344ae8b61c12b0ee455bf9a70d0
      3a1ff5668ca943e3092cc6779db852f2183dd7886247ad0de7c228997356
      bc1cf6d339aa40658f2fc5e00abb51749e3ed4f11bcc2603e949a3866cdd
      3712f858b2977dee0421cb6b81a44eff1530da7a90b55f0be1c42e8e6441
      ab1af0d53f9f7550ba29c3e60cac46638938d2f71dbd5772984fa5806aca
      2005ef5eb4917bdb3114fe6d87a248e80227cd7c96b359f91336dc83694c
      a606ecc92392785db717fdd832a14b6e8424ceeb01b05a7f9535dffa10c7
      2d08e242a88d67d63c1900ebcd26816a4ca719f2d43f987355be32d9ff14
      b3587e952bc0e60daa41678c648fa942e50e28c37d96b05bfc1731da56bd
      9b70d73c1af14fa48269ce2503e8c82305ee49a2846fd13a1cf750bb9d76
      fa1137dc7b90b65de3082ec56289af44ac47618a2dc6e00bb55e789334df
      f9129e7553b81ff4d239876c4aa106edcb208b6046ad0ae1c72c92795fb4
      13f8de35b952749f38d3f51ea04b6d8621caec07ef0422c96e85a348f61d
      3bd0779cba51dd3610fb5cb7917ac42f09e245ae886343a88e65c2290fe4
      5ab1977cdb3016fd719abc57f01b3dd66883a54ee90224cf27ccea01a64d
      6b803ed5f31800ecc32f9d715eb221cde20ebc507f9342ae816ddf331cf0
      638fa04cfe123dd1846847ab19f5da36a549668a38d4fb17c62a05e95bb7
      9874e70b24c87a96b95513ffd03c8e624da132def11daf436c8051bd927e
      cc200fe3709cb35fed012ec2977b54b80ae6c925b65a75992bc7e804d539
      16fa48a48b67f41837db6985aa4626cae509bb57789407ebc4289a7659b5
      6488a74bf9153ad645a9866ad8341bf7a24e618d3fd3fc10836f40ac1ef2
      dd31e00c23cf7d91be52c12d02ee5cb09f7335d9f61aa8446b8714f8d73b
      89654aa6779bb458ea0629c556ba9579cb2708e4b15d729e2cc0ef03907c
      53bf0d00edc12c997458b529c4e805b05d719c52bf937ecb260ae77b96ba
      57e20f23cea44965883dd0fc118d604ca114f9d538f61b37da6f82ae43df
      321ef346ab876a53be927fca270be67a97bb56e30e22cf01ecc02d987559
      b428c5e904b15c709df71a36db6e83af42de331ff247aa866ba54864893c
      d1fd108c614da015f8d439a64b678a3fd2fe138f624ea316fbd73af41935
      d86d80ac41dd301cf144a9856802efc32e9b765ab72bc6ea07b25f739e50
      bd917cc92408e57994b855e00d21ccf51834d96c81ad40dc311df045a884
      69a74a668b3ed3ff128e634fa217fad63b51bc907dc82509e47895b954e1
      0c00eec729957b52bc31dff618a44a638d628ca54bf71930de53bd947ac6
      2801efc42a03ed51bf9678f51b32dc608ea749a648618f33ddf41a977950
      be02ecc52b937d54ba06e8c12fa24c658b37d9f01ef11f36d8648aa34dc0
      2e07e955bb927c57b9907ec22c05eb6688a14ff31d34da35dbf21ca04e67
      8904eac32d917f56b83dd3fa14a8466f810ce2cb2599775eb05fb19876ca
      240de36e80a947fb153cd2f9173ed06c82ab45c8260fe15db39a749b755c
      b20ee0c927aa446d833fd1f816ae4069873bd5fc129f7158b60ae4cd23cc
      220be559b79e70fd133ad46886af416a84ad43ff1138d65bb59c72ce2009
      00efc52a917e54bb39d6fc13a8476d82729db758e30c26c94ba48e61da35
      1ff0e40b21ce759ab05fdd3218f74ca38966967953bc07e8c22daf406a85
      3ed1fb14d33c16f942ad8768ea052fc07b94be51a14e648b30dff51a9877
      5db209e6cc2337d8f21da649638c0ee1cb249f705ab545aa806fd43b11fe
      7c93b956ed0228c7bd5278972cc3e906846b41ae15fad03fcf200ae55eb1
      9b74f61933dc6788a24d59b69c73c8270de2608fa54af11e34db2bc4ee01
      ba557f9012fdd738836c46a96e81ab44ff103ad557b8927dc62903ec1cf3
      d9368d6248a725cae00fb45b719e8a654fa01bf4de31b35c769922cde708
      00f0fb0bed1d16e6c1313aca2cdcd7279969629274848f7f58a8a353b545
      4ebe29d9d222c4343fcfe81813e305f5fe0eb0404bbb5dada65671818a7a
      9c6c679752a2a959bf4f44b4936368987e8e8575cb3b30c026d6dd2d0afa
      f101e7171cec7b8b807096666d9dba4a41b157a7ac5ce21219e90ffff404
      23d3d828ce3e35c5a4545faf49b9b24265959e6e887873833dcdc636d020
      2bdbfc0c07f711e1ea1a8d7d768660909b6b4cbcb747a1515aaa14e4ef1f
      f90902f2d5252ede38c8c333f6060dfd1bebe01037c7cc3cda2a21d16f9f
      946482727989ae5e55a543b3b848df2f24d432c2c9391eeee515f30308f8
      4600f1f908e91810e1c93830c120d1d928897870816091996840b1b948a9
      5850a109f8f001e01119e8c03139c829d8d021807179886998906149b8b0
      41a05159a812e3eb1afb0a02f3db2a22d332c3cb3a9b6a629372838b7a52
      a3ab5abb4a42b31beae213f2030bfad2232bda3bcac23392636b9a7b8a82
      735baaa253b2434bba24d5dd2ccd3c34c5ed1c14e504f5fd0cad5c54a544
      b5bd4c64959d6c8d7c74852ddcd425c4353dcce4151dec0dfcf405a4555d
      ac4dbcb4456d9c946584757d8c36c7cf3edf2e26d7ff0e06f716e7ef1ebf
      4e46b756a7af5e76878f7e9f6e66973fcec637d6272fdef6070ffe1feee6
      17b64700f2ff0de5171ae8d1232edc34c6cb39b94b46b45caea351689a97
      658d7f7280699b96648c7e7381b84a47b55dafa250d0222fdd35c7ca3801
      f3fe0ce4161be9d2202ddf37c5c83a03f1fc0ee61419eb6b9994668e7c71
      83ba4845b75fada052bb4944b65eaca1536a9895678f7d708202f0fd0fe7
      1518ead3212cde36c4c93bbf4d40b25aa8a5576e9c91638b79748606f4f9
      0be3111ceed72528da32c0cd3fd62429db33c1cc3e07f5f80ae2101def6f
      9d90628a787587be4c41b35ba9a4566d9f9260887a7785bc4e43b159aba6
      54d4262bd931c3ce3c05f7fa08e0121fed04f6fb09e1131eecd5272ad830
      c2cf3dbd4f4200f3fd0ee1121cefd92a24d738cbc536a95a54a748bbb546
      70838d7e91626c9f49bab447a85b55a690636d9e71828c7fe0131dee01f2
      fc0f39cac437d82b25d692616f9c73808e7d4bb8b645aa5957a43bc8c635
      da2927d4e2111fec03f0fe0ddb2826d53ac9c73402f1ff0ce3101eed7281
      8f7c93606e9dab5856a54ab9b7443fccc231de2d23d0e6151be807f4fa09
      96656b9877848a794fbcb241ae5d53a076858b7897646a99af5c52a14ebd
      b340df2c22d13ecdc33006f5fb08e7141ae9ad5e50a34cbfb1427487897a
      9566689b04f7f90ae51618ebdd2e20d33ccfc132e41719ea05f6f80b3dce
      c033dc2f21d24dbeb04300f4f307fd090efae11512e61ce8ef1bd92d2ade
      24d0d72338cccb3fc53136c2a95d5aae54a0a75348bcbb4fb54146b27084
      83778d797e8a916562966c989f6b49bdba4eb44047b3a85c5baf55a1a652
      906463976d999e6a718582768c787f8be01413e71de9ee1a01f5f206fc08
      0ffb39cdca3ec43037c3d82c2bdf25d1d622926661956f9b9c6873878074
      8e7a7d894bbfb84cb64245b1aa5e59ad57a3a4503bcfc83cc63235c1da2e
      29dd27d3d420e21611e51febec1803f7f004fe0a0df9db2f28dc26d2d521
      3acec93dc73334c002f6f105ff0b0cf8e31710e41eeaed19728681758f7b
      7c88936760946e9a9d69ab5f58ac5600f5f104f90c08fde91c18ed10e5e1
      14c93c38cd30c5c13420d5d124d92c28dd897c788d708581746095916499
      6c689d40b5b144b94c48bda95c58ad50a5a15409fcf80df00501f4e01511
      e419ece81dc03531c439ccc83d29dcd82dd02521d480757184798c887d69
      9c986d9065619449bcb84db04541b4a05551a459aca85d12e7e316eb1e1a
      effb0e0aff02f7f306db2e2adf22d7d32632c7c336cb3e3acf9b6e6a9f62
      979366728783768b7e7a8f52a7a356ab5e5aafbb4e4abf42b7b3461beeea
      1fe21713e6f20703f60bfefa0fd22723d62bdeda2f3bceca3fc23733c692
      6763966b9e9a6f7b8e8a7f827773865baeaa5fa25700f6f701f50302f4f1
      0706f004f2f305f90f0ef80cfafb0d08feff09fd0b0afce91f1ee81ceaeb
      1d18eeef19ed1b1aec10e6e711e51312e4e11716e014e2e315c93f3ec83c
      cacb3d38cecf39cd3b3acc30c6c731c53332c4c13736c034c2c33520d6d7
      21d52322d4d12726d024d2d325d92f2ed82cdadb2d28dedf29dd2b2adc89
      7f7e887c8a8b7d788e8f798d7b7a8c708687718573728481777680748283
      7560969761956362949167669064929365996f6e986c9a9b6d689e9f699d
      6b6a9c40b6b741b54342b4b14746b044b2b345b94f4eb84cbabb4d48bebf
      49bd4b4abca95f5ea85caaab5d58aeaf59ad5b5aac50a6a751a5535200f7
      f502f10604f3f90e0cfb08fffd0ae91e1ceb18efed1a10e7e512e11614e3
      c93e3ccb38cfcd3a30c7c532c13634c320d7d522d12624d3d92e2cdb28df
      dd2a897e7c8b788f8d7a70878572817674836097956291666493996e6c9b
      689f9d6a40b7b542b14644b3b94e4cbb48bfbd4aa95e5cab58afad5a50a7
      a552a15654a309fefc0bf80f0dfaf00705f201f6f403e01715e211e6e413
      19eeec1be81f1deac03735c231c6c43339cecc3bc83f3dca29dedc2bd82f
      2ddad02725d221d6d4238077758271868473798e8c7b887f7d8a699e9c6b
      986f6d9a906765926196946349bebc4bb84f4dbab04745b241b6b443a057
      55a251a6a45300f8eb13cd3526de81796a924cb4a75f19e1f20ad42c3fc7
      9860738b55adbe4632cad921ff0714ecb34b58a07e86956d2bd3c038e61e
      0df5aa5241b9679f8c74649c8f77a95142bae51d0ef628d0c33b7d85966e
      b0485ba3fc0417ef31c9da2256aebd459b637088d72f3cc41ae2f1094fb7
      a45c827a6991ce3625dd03fbe810c83023db05fdee1649b1a25a847c6f97
      d1293ac21ce4f70f50a8bb439d65768efa0211e937cfdc247b839068b64e
      5da5e31b08f02ed6c53d629a8971af5744bcac5447bf61998a722dd5c63e
      e0180bf3b54d5ea67880936b34ccdf27f90112ea9e66758d53abb8401fe7
      f40cd22a39c1877f6c944ab2a1590600f9e910c93020d98970609940b9a9
      5009f0e019c03929d08079699049b0a05912ebfb02db2232cb9b62728b52
      abbb421be2f20bd22b3bc2926b7b825ba2b24b24ddcd34ed1404fdad5444
      bd649d8d742dd4c43de41d0df4a45d4db46d94847d36cfdf26ff0616efbf
      4656af768f9f663fc6d62ff60f1fe6b64f5fa67f86966f48b1a158817868
      91c13828d108f1e11841b8a85188716198c83121d801f8e8115aa3b34a93
      6a7a83d32a3ac31ae3f30a53aaba439a63738ada2333ca13eafa036c9585
      7ca55c4cb5e51c0cf52cd5c53c659c8c75ac5545bcec1505fc25dccc357e
      87976eb74e5ea7f70e1ee73ec7d72e778e9e67be4757aefe0700faef15c5
      3f2ad0916b7e8454aebb4139c3d62cfc0613e9a85247bd6d97827872889d
      67b74d58a2e3190cf626dcc9334bb1a45e8e74619bda2035cf1fe5f00ae4
      1e0bf121dbce34758f9a60b04a5fa5dd2732c818e2f70d4cb6a359897366
      9c966c798353a9bc4607fde812c2382dd7af5540ba6a90857f3ec4d12bfb
      0114eed3293cc616ecf90342b8ad57877d6892ea1005ff2fd5c03a7b8194
      6ebe4451aba15b4eb4649e8b7130cadf25f50f1ae09862778d5da7b24809
      f3e61ccc3623d937cdd822f2081de7a65c49b363998c760ef4e11bcb3124
      de9f65708a5aa0b54f45bfaa50807a6f95d42e3bc111ebfe047c869369b9
      4356aced170200fbed16c13a2cd79962748f58a3b54e29d2c43fe81305fe
      b04b5da6718a9c6752a9bf4493687e85cb3026dd0af1e71c7b80966dba41
      57ace2190ff423d8ce35a45f49b2659e88733dc6d02bfc0711ea8d76609b
      4cb7a15a14eff902d52e38c3f60d1be037ccda216f948279ae5543b8df24
      32c91ee5f30846bdab50877c6a9153a8be4592697f84ca3127dc0bf0e61d
      7a81976cbb4056ade3180ef522d9cf3401faec17c03b2dd69863758e59a2
      b44f28d3c53ee91204ffb14a5ca7708b9d66f70c1ae136cddb206e958378
      af5442b9de2533c81fe4f20947bcaa51867d6b90a55e48b3649f89723cc7
      d12afd0610eb8c77619a4db6a05b15eef80300fce31fdd213ec2a15d42be
      7c809f6359a5ba468478679bf8041be725d9c63ab24e51ad6f938c7013ef
      f00cce322dd1eb1708f436cad5294ab6a955976b74887f839c60a25e41bd
      de223dc103ffe01c26dac539fb0718e4877b64985aa6b945cd312ed210ec
      f30f6c908f73b14d52ae9468778b49b5aa5635c9d62ae8140bf7fe021de1
      23dfc03c5fa3bc40827e619da75b44b87a86996506fae519db2738c44cb0
      af53916d728eed110ef230ccd32f15e9f60ac8342bd7b44857ab69958a76
      817d629e5ca0bf4320dcc33ffd011ee2d8243bc705f9e61a79859a66a458
      47bb33cfd02cee120df1926e718d4fb3ac506a968975b74b54a8cb3728d4
      1600fde11cd92438c5a95448b5708d916c49b4a855906d718ce01d01fc39
      c4d825926f738e4bb6aa573bc6da27e21f03fedb263ac702ffe31e728f93
      6eab564ab73fc2de23e61b07fa966b778a4fb2ae53768b976aaf524eb3df
      223ec306fbe71aad504cb17489956804f9e518dd203cc1e41905f83dc0dc
      214db0ac51946975887e839f62a75a46bbd72a36cb0ef3ef1237cad62bee
      130ff29e637f8247baa65bec110df035c8d42945b8a4599c617d80a55844
      b97c819d600cf1ed10d52834c941bca05d98657984e81509f431ccd02d08
      f5e914d12c30cda15c40bd78859964d32e32cf0af7eb167a879b66a35e42
      bf9a677b8643bea25f33ced22fea1700fee719d52b32ccb14f56a8649a83
      7d79879e60ac524bb5c8362fd11de3fa04f20c15eb27d9c03e43bda45a96
      68718f8b756c925ea0b9473ac4dd23ef1108f6ff0118e62ad4cd334eb0a9
      579b657c828678619f53adb44a37c9d02ee21c05fb0df3ea14d8263fc1bc
      425ba569978e70748a936da15f46b8c53b22dc10eef709e51b02fc30ced7
      2954aab34d817f66989c627b8549b7ae502dd3ca34f8061fe117e9f00ec2
      3c25dba65841bf738d946a6e908977bb455ca2df2138c60af4ed131ae4fd
      03cf3128d6ab554cb27e809967639d847ab64851afd22c35cb07f9e01ee8
      160ff13dc3da2459a7be408c726b95916f768844baa35d20dec739f50b12
      00ffe51ad12e34cbb9465ca368978d7269968c73b8475da2d02f35ca01fe
      e41bd22d37c803fce6196b948e71ba455fa0bb445ea16a958f7002fde718
      d32c36c9bf405aa56e918b7406f9e31cd72832cdd62933cc07f8e21d6f90
      8a75be415ba46d928877bc4359a6d42b31ce05fae01f04fbe11ed52a30cf
      bd4258a76c938976659a807fb44b51aedc2339c60df2e8170cf3e916dd22
      38c7b54a50af649b817eb74852ad6699837c0ef1eb14df203ac5de213bc4
      0ff0ea156798827db64953acda253fc00bf4ee11639c8679b24d57a8b34c
      56a9629d87780af5ef10db243ec108f7ed12d9263cc3b14e54ab609f857a
      619e847bb04f55aad8273dc209f6ec13
END
   pack 'H*', $whole =~ s{\s+}{}rgmxs;
} ## end sub GF_2_8_table

1;

__END__

=pod

=encoding utf-8

=head1 NAME

AesBasic - basic operations with AES (NIST FIPS-197)

=head1 SYNOPSIS

   # Some starting things...
   my $plaintext  = pack 'H*', '00112233445566778899aabbccddeeff';
   my $key        = pack 'H*', '000102030405060708090a0b0c0d0e0f';
   # Everything should also work with $key lengths of 24 and 32 octets


   # High-level API, one-shot functions
   use AesBasic ':one_shot';

   my $encrypted = block_encrypt($plaintext, $key);
   die "encryption failure!\n"
      if $encrypted ne pack 'H*', '69c4e0d86a7b0430d8cdb78070b4c55a';

   my $decrypted = block_encrypt($encrypted, $key);
   die "decryption failure!\n"
      if $decrypted ne $plaintext;


   # High-level API, factory functions for multiple use of same key
   use AesBasic ':factory';
   
   my $encrypter = block_encrypter($key);
   print $encrypter->($_) for @plaintext_blocks;

   my $decrypter = block_decrypter($key);
   print $decrypter->($_) for @encrypted_blocks;


   # Low-level API
   use AesBasic ':low_level';

   my $multiplication = GF_2_8_mult("\x57", "\x83"); # --> "\xc1"

   # this is "medium-level" API
   my $key_schedule_direct = key_expansion($key);
   my $encrypted = cipher($plaintext, $key_schedule_direct);
   my $decrypted = inv_cipher($encrypted, $key_schedule_direct);

   # equivalent inverse cipher, using a modified key scheduling
   my $key_schedule_mod = modify_key_schedule_copy($key_schedule_direct);
   my $decrypted_eq = equivalent_inv_cipher($encrypted, $key_schedule_mod);

   # lower-level basic operations act in-place and return $state, so they
   # can be called one inside the other
   my $state = [ split m{}mxs, $plaintext ];
   add_round_key($state, $key_part);
   shift_rows(sub_bytes($state));  # can call like Matrioska
   mix_columns($state);
   inv_mix_columns($state);
   inv_shift_rows($state);
   inv_sub_bytes($state);
   
   my $word = 'ABCD'; # 4 bytes
   my $rotated = rot_word($word); # -> 'BCDA'
   my $subbed  = sub_word($word); # -> "\x83\x2c\x1a\x1b"

=head1 DESCRIPTION

Take a look at the L</SYNOPSIS>.

=head1 AUTHOR

Flavio Poletti <flavio[at]polettix.it>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 by Flavio Poletti <flavio[at]polettix.it>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut
