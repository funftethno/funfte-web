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

# Ancho y alto de una imagen JPEG, PNG o GIF leyendo su cabecera (sin modulos externos).
my %dimensiones;
sub dimensiones {
    my ($archivo) = @_;
    return @{ $dimensiones{$archivo} } if $dimensiones{$archivo};
    open my $fh, '<:raw', $archivo or return;
    read $fh, my $cab, 26;
    my @d;
    if ($cab =~ /^\x89PNG/) {
        @d = unpack 'NN', substr($cab, 16, 8);
    } elsif ($cab =~ /^GIF8/) {
        @d = unpack 'vv', substr($cab, 6, 4);
    } elsif ($cab =~ /^\xFF\xD8/) {
        seek $fh, 2, 0;
        while (read($fh, my $marca, 4) == 4) {
            my ($ff, $tipo, $largo) = unpack 'CCn', $marca;
            last if $ff != 0xFF;
            if ($tipo >= 0xC0 && $tipo <= 0xCF && $tipo != 0xC4 && $tipo != 0xC8 && $tipo != 0xCC) {
                read $fh, my $sof, 5;
                my ($alto, $ancho) = unpack 'xnn', $sof;
                @d = ($ancho, $alto);
                last;
            }
            seek $fh, $largo - 2, 1;
        }
    }
    close $fh;
    return unless @d == 2 && $d[0] && $d[1];
    $dimensiones{$archivo} = \@d;
    return @d;
}

# Agrega width y height a las imagenes locales que no los tengan: evita que la
# pagina salte mientras cargan las fotos (el CSS mantiene la proporcion).
sub con_dimensiones {
    my ($ruta, $html) = @_;
    $html =~ s{<img\b([^>]*)>}{
        my $atr = $1;
        if ($atr !~ /\bwidth=/ && $atr =~ /\bsrc="([^":]+)"/) {
            my @d = dimensiones("$RAIZ/$ruta$1");
            $atr =~ s{\bsrc="[^"]*"\K}{ width="$d[0]" height="$d[1]"} if @d;
        }
        "<img$atr>";
    }ge;
    return $html;
}

sub escribir_archivo {
    my ($nombre, $texto) = @_;
    open my $fh, '>:encoding(UTF-8)', "$RAIZ/$nombre" or die "$nombre: $!";
    print $fh $texto;
    close $fh;
    print "  -> $nombre\n";
}

sub escribir {
    my ($ruta, $html) = @_;
    $html = con_dimensiones($ruta, $html);
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

# Pagina 404: Cloudflare la sirve en cualquier direccion inexistente (wrangler.jsonc),
# por eso usa rutas absolutas (prefijo "/").
print "Página no encontrada\n";
escribir_archivo('404.html', con_dimensiones('', pagina(
    clave => 'error404', ruta => '', prefijo => '/', titulo => 'Página no encontrada', seccion => '',
    descripcion => 'La página que buscas no existe o cambió de dirección.',
    contenido => qq(<p>La página que buscas no existe o cambió de dirección.</p>\n<p><a href="/">Volver a la portada</a> · <a href="/contacto/">Contacto</a></p>),
)));

# robots.txt y sitemap.xml: solo las paginas publicas (el Archivo queda fuera)
my @publicas = sort grep { $_ !~ m{^(?:archivo|postula/gracias)/} } map { $_->{ruta} } values %paginas;
escribir_archivo('sitemap.xml', qq(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n)
    . join('', map { "  <url><loc>$plantilla::SITIO$_</loc></url>\n" } @publicas) . "</urlset>\n");
escribir_archivo('robots.txt', "User-agent: *\nAllow: /\n\nSitemap: ${plantilla::SITIO}sitemap.xml\n");
print "Listo.\n";
