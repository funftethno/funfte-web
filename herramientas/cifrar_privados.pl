#!/usr/bin/perl
# Cifra los datos privados de los voluntarios (generacion y numero de registro) que muestra la
# pagina Dotacion con fotos al ingresar la contraseña.
#
# Uso (desde la raiz del repositorio):
#   CLAVE='contraseña' perl herramientas/cifrar_privados.pl ruta/voluntarios-privados.txt
#
# El archivo tiene una linea por voluntario, "Nombre | generacion | registro", con el nombre
# escrito igual que en dotacion.html; un dato que falta se deja vacio. Por ejemplo:
#   Fernando Vera Torres | 2009 |
# Vive en el repositorio privado de administracion: estos datos NO van en este repositorio.
# Escribe herramientas/contenido/privados.cifrado, que si se sube, y despues hay que correr
# generar.pl. Usa "openssl enc" (AES-256-CBC con clave PBKDF2-SHA256); privados.js lo
# descifra en el navegador con la misma contraseña.
use strict;
use warnings;
use FindBin;

my $ITERACIONES = 200000;
my $archivo = shift or die "Uso: CLAVE='...' perl herramientas/cifrar_privados.pl voluntarios-privados.txt\n";
die "Falta la contraseña en la variable CLAVE.\n" unless length($ENV{CLAVE} // '');

sub texto_json { my ($t) = @_; $t =~ s/(["\\])/\\$1/g; return qq("$t") }

open my $fh, '<', $archivo or die "$archivo: $!\n";
my @voluntarios;
while (<$fh>) {
    next if /^\s*(?:#|$)/;
    my ($nombre, $generacion, $registro) = map { s/^\s+|\s+$//gr } split /\|/, $_, -1;
    die "Línea no válida en $archivo: $_" unless length($nombre // '') && defined $generacion;
    die "Generación no válida en $archivo: $_" if length $generacion && $generacion !~ /^\d{4}$/;
    my @datos;
    push @datos, '"generacion":' . texto_json($generacion) if length $generacion;
    push @datos, '"registro":' . texto_json($registro) if length($registro // '');
    push @voluntarios, texto_json($nombre) . ':{' . join(',', @datos) . '}';
}
close $fh;

my $json = '{' . join(',', @voluntarios) . '}';
open my $enc, '-|', 'sh', '-c', 'printf %s "$0" | openssl enc -aes-256-cbc -pbkdf2 -iter "$1" -md sha256 -salt -base64 -A -pass env:CLAVE',
    $json, $ITERACIONES or die "openssl: $!\n";
my $cifrado = <$enc>;
close $enc or die "openssl falló\n";

my $salida = "$FindBin::Bin/contenido/privados.cifrado";
open my $out, '>', $salida or die "$salida: $!\n";
print $out qq({"iteraciones":$ITERACIONES,"datos":"$cifrado"}\n);
close $out;
print scalar(@voluntarios), " voluntarios cifrados en herramientas/contenido/privados.cifrado\n";
