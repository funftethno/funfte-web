#!/usr/bin/perl
# Importa el contenido del sitio WordPress actual (www.funfte.cl/sitio) y genera
# el sitio estatico en la raiz del repositorio. Se excluye la seccion Noticias.
#
# Uso (desde la raiz del repositorio):  perl herramientas/importar.pl
#
# Descarga cada pagina, limpia el HTML del tema Enfold, baja las imagenes a
# assets/img/ y escribe cada pagina usando la plantilla de herramientas/plantilla.pm.
use strict;
use warnings;
use utf8;
use HTML::Parser;
use File::Path qw(make_path);
use File::Basename qw(dirname);
use FindBin;
use lib $FindBin::Bin;
use plantilla qw(pagina rutas_paginas);

binmode STDOUT, ':utf8';

my $ORIGEN = 'http://www.funfte.cl/sitio/';
my $RAIZ   = "$FindBin::Bin/..";
# Copia del HTML del sitio antiguo: permite regenerar sin que funfte.cl siga en linea.
# Para volver a descargar una pagina, borra su archivo de esta carpeta.
my $CACHE  = "$FindBin::Bin/origen";
make_path($CACHE, "$RAIZ/assets/img");

my %paginas = rutas_paginas();

# Enlaces del sitio antiguo -> rutas nuevas (relativas a la raiz)
my %mapa_enlaces = (
    'page_id=1195' => 'la-quinta/',
    'page_id=1670' => 'historia/',
    'page_id=1792' => 'cuartel/',
    'page_id=1738' => 'confederacion/',
    'page_id=1826' => 'socios-colaboradores/',
    'page_id=1899' => 'dotacion/',
    'page_id=1911' => 'directorio/',
    'page_id=1928' => 'nuestro-trabajo/',
    'page_id=1940' => 'capacitacion/',
    'page_id=1946' => 'guardia-nocturna/',
    'page_id=1962' => 'redes-sociales/',
    'page_id=1097' => 'material-mayor/',
    'page_id=1167' => 'contacto/',
    'portfolio=lorem-ipsum'      => 'material-mayor/bx-5/',
    'portfolio=unidad-br-5'      => 'material-mayor/b-5/',
    'portfolio=unidad-harbor-28' => 'material-mayor/harbor-28/',
);

# ---------------------------------------------------------------- descargas

sub descargar {
    my ($url, $destino) = @_;
    return 1 if -s $destino;
    my $r = system('curl', '-sSfL', '--retry', '2', '-o', $destino, $url);
    if ($r != 0) { unlink $destino; warn "  ! no se pudo descargar $url\n"; return 0 }
    return 1;
}

sub leer_utf8 {
    my ($archivo) = @_;
    open my $fh, '<:encoding(UTF-8)', $archivo or die "$archivo: $!";
    local $/;
    my $t = <$fh>;
    close $fh;
    return $t;
}

my %imagen_local;      # url -> nombre de archivo local
my %nombre_usado;      # nombre en minusculas -> url (Windows no distingue mayusculas)

sub imagen {
    my ($url) = @_;
    $url =~ s/^https:/http:/;
    return $imagen_local{$url} if exists $imagen_local{$url};
    my ($anio, $mes, $base) = $url =~ m{/uploads/(\d{4})/(\d{2})/([^/?#]+)$};
    ($base) = $url =~ m{/([^/?#]+)$} unless $base;
    $base =~ s/%([0-9A-Fa-f]{2})/chr(hex $1)/ge;
    utf8::decode($base);
    $base =~ tr/áéíóúÁÉÍÓÚñÑüÜ/aeiouAEIOUnNuU/;
    $base =~ s/[^A-Za-z0-9._-]+/-/g;
    my $nombre = $anio ? "$anio-$mes-$base" : $base;
    my ($raiz, $ext) = $nombre =~ /^(.*?)(\.[^.]+)?$/;
    $ext //= '';
    my $n = 2;
    while (exists $nombre_usado{lc $nombre} && $nombre_usado{lc $nombre} ne $url) {
        $nombre = "$raiz-$n$ext";
        $n++;
    }
    $nombre_usado{lc $nombre} = $url;
    descargar($url, "$RAIZ/assets/img/$nombre");
    return $imagen_local{$url} = $nombre;
}

# ------------------------------------------------------------- limpieza HTML

my %permitidas = map { $_ => 1 } qw(h1 h2 h3 h4 h5 h6 p ul ol li strong em a img br
                                    table thead tbody tr td th blockquote);
my %renombrar = (b => 'strong', i => 'em');
my %vacias    = map { $_ => 1 } qw(img br hr input meta link source col wbr area embed param);
my %descartar_tag = map { $_ => 1 } qw(script style noscript form iframe svg header nav);
my $descartar_clase = qr/\b(?:sidebar|comment-entry|title_container|post-meta-infos|avia-post-nav|
    avia_search|av-share-box|avia-slideshow-arrows|avia-slideshow-dots|sort_width_container|
    toggler|footer_color|socket|related_posts|avia-testimonial-arrow-wrap|avia-related)\b/x;
my $icono = qr/^[\s\x{E000}-\x{F8FF}\x{1F000}-\x{1FFFF}\x{2600}-\x{27BF}\x{2190}-\x{21FF}]+$/;

sub ceros { my $t = shift; $t =~ s/(?<=\d)O|O(?=\d)/0/g; $t }

sub atr { my $v = shift; $v =~ s/&/&amp;/g; $v =~ s/"/&quot;/g; $v =~ s/</&lt;/g; $v }

sub enlace_nuevo {
    my ($href, $prefijo) = @_;
    return undef if !defined $href || $href eq '' || $href =~ /^#/;
    return undef if $href =~ /mafiashare/i;
    if ($href =~ m{funfte\.cl/sitio/?(?:\?(.*))?$}) {
        my $q = $1 // '';
        return $prefijo if $q eq '';
        return undef if $q =~ /^(?:p|m|s|cat|page_id=731)\b/;   # noticias, archivos, busqueda
        return exists $mapa_enlaces{$q} ? $prefijo . $mapa_enlaces{$q} : undef;
    }
    return $href;
}

sub limpiar {
    my ($html, $prefijo) = @_;
    my $salida = '';
    my @pila;            # [tag, accion] accion: emit|unwrap|skip|imglink|grid
    my $saltando = 0;    # profundidad dentro de un elemento descartado
    my $capturando = 0;
    my %vistas;          # imagenes ya incluidas (galerias repiten la primera)
    my $href_imagen;

    my $p = HTML::Parser->new(
        api_version => 3,
        start_h => [sub {
            my ($tag, $a) = @_;
            if (!$capturando) {
                $capturando = 1 if $tag eq 'div' && ($a->{id} // '') eq 'main';
                return;
            }
            my $clase = $a->{class} // '';
            my $id    = $a->{id} // '';
            if ($saltando) { $saltando++ unless $vacias{$tag}; return }
            if ($descartar_tag{$tag} || $clase =~ $descartar_clase || $id =~ /^(?:comments|footer|socket)$/) {
                $saltando = 1 unless $vacias{$tag};
                return;
            }
            if ($clase =~ /\bgrid-sort-container\b/) {
                $salida .= "\n<!--UNIDADES-->\n";
                $saltando = 1;
                return;
            }
            # Confederacion: tarjetas de compañias (testimoniales de Enfold)
            if ($tag eq 'div' && $clase =~ /\bavia-testimonial\b/ && $clase !~ /row/) {
                $salida .= '<article class="cia">';
                push @pila, [$tag, 'cia'];
                return;
            }
            if ($clase =~ /\bavia-testimonial-name\b/)     { $salida .= '<h4>'; push @pila, [$tag, 'h4'];  return }
            if ($clase =~ /\bavia-testimonial-subtitle\b/) { $salida .= '<p class="cia-dir">'; push @pila, [$tag, 'p']; return }

            my $t = $renombrar{$tag} // $tag;
            if ($t eq 'a' && ($a->{href} // '') =~ /\.(?:jpe?g|png|gif)$/i) {
                $href_imagen = $a->{href};
                push @pila, [$tag, 'imglink'];
                return;
            }
            if ($t eq 'img') {
                my $src = $href_imagen // $a->{src} // return;
                undef $href_imagen;
                (my $clave = $src) =~ s/-\d+x\d+(\.\w+)$/$1/;
                return if $vistas{$clave}++;
                my $local = imagen($src);
                my $alt = ceros($a->{alt} // '');
                $salida .= sprintf '<img src="%sassets/img/%s" alt="%s" loading="lazy">', $prefijo, $local, atr($alt);
                return;
            }
            if ($t eq 'a') {
                my $nuevo = enlace_nuevo($a->{href}, $prefijo);
                if (defined $nuevo) {
                    my $ext = $nuevo =~ /^https?:/ ? ' target="_blank" rel="noopener"' : '';
                    $salida .= sprintf '<a href="%s"%s>', atr($nuevo), $ext;
                    push @pila, [$tag, 'a'];
                } else {
                    push @pila, [$tag, 'unwrap'];
                }
                return;
            }
            if ($t eq 'br') { $salida .= '<br>'; return }
            return if $vacias{$tag};
            if ($permitidas{$t}) {
                my $extra = '';
                for my $k (qw(colspan rowspan)) { $extra .= qq( $k="$a->{$k}") if defined $a->{$k} }
                $salida .= "<$t$extra>";
                push @pila, [$tag, $t];
            } else {
                push @pila, [$tag, 'unwrap'];
            }
        }, 'tagname, attr'],
        end_h => [sub {
            my ($tag) = @_;
            return unless $capturando;
            return if $vacias{$tag};
            if ($saltando) { $saltando--; return }
            # buscar el elemento abierto correspondiente
            my $i = $#pila;
            $i-- while $i >= 0 && $pila[$i][0] ne $tag;
            return if $i < 0;
            while (@pila > $i) {
                my ($t, $accion) = @{ pop @pila };
                if    ($accion eq 'cia')     { $salida .= '</article>' }
                elsif ($accion eq 'imglink') { undef $href_imagen }
                elsif ($accion ne 'unwrap')  { $salida .= "</$accion>" }
            }
        }, 'tagname'],
        text_h => [sub {
            my ($texto) = @_;
            return if !$capturando || $saltando;
            return if $texto =~ $icono && $texto =~ /\S/;
            $salida .= ceros($texto);
        }, 'text'],
    );
    $p->empty_element_tags(1);
    $p->parse($html);
    $p->eof;

    # limpieza final
    $salida =~ s/&nbsp;|\x{A0}/ /g;
    $salida =~ s/[ \t]+/ /g;
    $salida =~ s/\s*\n\s*/\n/g;
    1 while $salida =~ s{<(p|li|h[1-6]|strong|em|a|blockquote|ul|ol)\b[^>]*>(?:\s|<br>)*</\1>}{}g;
    $salida =~ s{<p>\s*(?:<br>\s*)+}{<p>}g;
    $salida =~ s{(?:\s*<br>)+\s*</p>}{</p>}g;
    $salida =~ s{<br>\s*</strong>\s*</p>}{</strong></p>}g;
    $salida =~ s/^\s+|\s+$//g;
    return $salida;
}

# ---------------------------------------------------------------- paginas

sub tarjetas_unidades {
    my ($prefijo, $excluir) = @_;
    my @u = (
        ['material-mayor/bx-5/',      'Unidad BX-5',      'Iveco Magirus FF150E30W 4x4. Unidad mixta de incendio y rescate.',
         'http://www.funfte.cl/sitio/wp-content/uploads/2013/04/484062_481579278523679_1418647621_n.jpg'],
        ['material-mayor/b-5/',       'Unidad B-5',       'Iveco Magirus FF150E30. Unidad de control de incendios.',
         'http://www.funfte.cl/sitio/wp-content/uploads/2013/06/IMG_2512-1030x686.jpg'],
        ['material-mayor/harbor-28/', 'Unidad Harbor 28', 'Embarcación de rescate medioambiental para descontaminación de aguas.',
         'http://www.funfte.cl/sitio/wp-content/uploads/2013/04/5611_227197685467_7138323_n.jpg'],
    );
    my $h = '';
    for my $x (@u) {
        next if $excluir && $x->[0] eq $excluir;
        my $img = imagen($x->[3]);
        $h .= qq(<a class="tarjeta-unidad" href="$prefijo$x->[0]"><img src="${prefijo}assets/img/$img" alt="$x->[1]" loading="lazy"><span class="tarjeta-texto"><strong>$x->[1]</strong><span>$x->[2]</span></span></a>\n);
    }
    return qq(<div class="grilla-unidades">\n$h</div>);
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
    next unless $pg->{origen};
    print "$pg->{titulo}\n";
    my $cache = "$CACHE/$clave.html";
    descargar($ORIGEN . $pg->{origen}, $cache) or die "no se pudo descargar $pg->{titulo}\n";
    my $prefijo = '../' x ($pg->{ruta} =~ tr{/}{});
    my $contenido = limpiar(leer_utf8($cache), $prefijo);

    if ($clave eq 'material') {
        $contenido =~ s/<!--UNIDADES-->/tarjetas_unidades($prefijo)/e;
        # las descripciones breves de cada unidad ya estan en las tarjetas
        $contenido =~ s{\n?<h3>Unidad Iveco.*$}{}s;
    } elsif ($pg->{ruta} =~ m{^material-mayor/.}) {
        # sin el listado de material menor de cada unidad
        $contenido =~ s{<p>(?:<strong>)?Material(?:</strong>)?</p>\s*<p>.*?</p>\s*}{}s;
        $contenido =~ s{<!--UNIDADES-->}{qq(<h2 class="otras">Otras unidades</h2>\n) . tarjetas_unidades($prefijo, $pg->{ruta})}e;
    }
    $contenido =~ s/<!--UNIDADES-->//g;
    if ($clave eq 'trabajo') {
        # el texto original repite un fragmento por error de copia
        $contenido =~ s{(Academia Nacional de Bomberos\.) correr de los años.*?de manera eficiente\.}{$1}s;
    }
    if ($clave eq 'contacto') {
        $contenido =~ s{<h3>Contáctate con nosotros</h3>}{<h3>Contáctate con nosotros</h3>\n<p>Escríbenos a <a href="mailto:correo\@funfte.cl">correo\@funfte.cl</a> o llámanos a la mesa central <a href="tel:+56412588000">+56 41 258 8000</a>.</p>\n<div class="mapa"><iframe title="Ubicación del cuartel" src="https://maps.google.com/maps?q=-36.763267,-73.092603&amp;z=16&amp;output=embed" loading="lazy"></iframe></div>};
    }

    escribir($pg->{ruta}, pagina(%$pg, clave => $clave, contenido => $contenido, imagen => \&imagen));
}

# Paginas con contenido propio (portada sin noticias, formacion, acceso quintino)
for my $clave (qw(inicio formacion acceso)) {
    my $pg = $paginas{$clave};
    print "$pg->{titulo}\n";
    escribir($pg->{ruta}, pagina(%$pg, clave => $clave, contenido => '', imagen => \&imagen));
}

# Logo
descargar('http://www.funfte.cl/sitio/wp-content/themes/enfold/images/layout/logo.png', "$RAIZ/assets/img/logo.png");
print "Listo.\n";
