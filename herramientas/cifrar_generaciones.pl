#!/usr/bin/perl
# Cifra la generacion (año de ingreso) de los voluntarios para la pagina Dotacion con fotos.
#
# Uso (desde la raiz del repositorio):
#   CLAVE='contraseña' perl herramientas/cifrar_generaciones.pl ruta/generaciones.txt
#
# generaciones.txt tiene una linea por voluntario, "<registro> <año>" (por ejemplo "063 2009"),
# y vive en el repositorio privado de administracion: los años NO van en este repositorio.
# Escribe herramientas/contenido/generaciones.cifrado, que si se sube, y despues hay que
# correr generar.pl. Usa "openssl enc" (AES-256-CBC con clave PBKDF2-SHA256); generaciones.js
# lo descifra en el navegador con la misma contraseña.
use strict;
use warnings;
use FindBin;

my $ITERACIONES = 200000;
my $archivo = shift or die "Uso: CLAVE='...' perl herramientas/cifrar_generaciones.pl generaciones.txt\n";
die "Falta la contraseña en la variable CLAVE.\n" unless length($ENV{CLAVE} // '');

open my $fh, '<', $archivo or die "$archivo: $!\n";
my @pares;
while (<$fh>) {
    next if /^\s*(?:#|$)/;
    /^\s*(\S+)\s+(\d{4})\s*$/ or die "Línea no válida en $archivo: $_";
    push @pares, qq("$1":"$2");
}
close $fh;

my $json = '{' . join(',', @pares) . '}';
open my $enc, '-|', 'sh', '-c', 'printf %s "$0" | openssl enc -aes-256-cbc -pbkdf2 -iter "$1" -md sha256 -salt -base64 -A -pass env:CLAVE',
    $json, $ITERACIONES or die "openssl: $!\n";
my $cifrado = <$enc>;
close $enc or die "openssl falló\n";

my $salida = "$FindBin::Bin/contenido/generaciones.cifrado";
open my $out, '>', $salida or die "$salida: $!\n";
print $out qq({"iteraciones":$ITERACIONES,"datos":"$cifrado"}\n);
close $out;
print scalar(@pares), " generaciones cifradas en herramientas/contenido/generaciones.cifrado\n";
