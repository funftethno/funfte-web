#!/usr/bin/perl
# Genera el sitio estatico en la raiz del repositorio.
#
# Uso (desde la raiz del repositorio):  perl herramientas/generar.pl
#
# El contenido de cada pagina esta en herramientas/contenido/<clave>.html y se
# envuelve con la plantilla de herramientas/plantilla.pm (cabecera, menu y pie).
# Las rutas de imagenes y enlaces dentro del contenido son relativas a la pagina.
use strict;
use warnings;
use utf8;
use File::Path qw(make_path);
use File::Basename qw(dirname);
use FindBin;
use lib $FindBin::Bin;
use plantilla qw(pagina rutas_paginas);

binmode STDOUT, ':utf8';

my $RAIZ      = "$FindBin::Bin/..";
my $CONTENIDO = "$FindBin::Bin/contenido";

my %paginas = rutas_paginas();

sub leer_utf8 {
    my ($archivo) = @_;
    open my $fh, '<:encoding(UTF-8)', $archivo or die "$archivo: $!";
    local $/;
    my $t = <$fh>;
    close $fh;
    $t =~ s/\s+$//;
    return $t;
}

sub escribir {
    my ($ruta, $html) = @_;
    my $archivo = "$RAIZ/${ruta}index.html";
    make_path(dirname($archivo));
    open my $fh, '>:encoding(UTF-8)', $archivo or die "$archivo: $!";
    print $fh $html;
    close $fh;
    print "  -> ${ruta}index.html\n";
}

for my $clave (sort keys %paginas) {
    my $pg = $paginas{$clave};
    print "$pg->{titulo}\n";
    # portada, formacion y acceso quintino tienen su contenido en plantilla.pm
    my $archivo = "$CONTENIDO/$clave.html";
    my $contenido = -e $archivo ? leer_utf8($archivo) : '';
    escribir($pg->{ruta}, pagina(%$pg, clave => $clave, contenido => $contenido));
}
print "Listo.\n";
