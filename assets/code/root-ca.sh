#!/bin/sh

cmd_create() {
   openssl req -new -x509 -out ca.crt -days 3650 \
      -subj '/CN=root-ca.example.org/C=IT/ST=Roma/L=Roma/O=What/OU=Ever' \
      -newkey rsa:2048 -nodes -keyout ca.key
}

cmd_sign() {
   local csr="$1"
   local crt="${csr%.csr}.crt"
   openssl x509 -req -in "$csr"  -out "$crt" \
      -CA ca.crt -CAkey ca.key -CAcreateserial
}

main() {
   local cmd="$1"
   shift
   "cmd_$cmd" "$@"
}

main "$@"
