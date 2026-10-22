#!/usr/bin/perl
# Revisa que las paginas generadas esten al dia y que no haya enlaces internos rotos.
#
# Uso (desde la raiz del repositorio):  perl herramientas/revisar.pl
#
# Regenera el sitio con generar.pl; si alguna pagina cambia, es que no se
# regenero antes de subir. Luego busca en cada index.html los href y src
# relativos y comprueba que el archivo de destino exista.
use strict;
use warnings;
use File::Find;
use File::Basename qw(dirname);
use File::Spec;
use Cwd qw(abs_path);
use FindBin;

my $RAIZ = abs_path("$FindBin::Bin/..");
chdir $RAIZ or die "$RAIZ: $!";
my $errores = 0;

sub paginas {
    my @p;
    find(sub { push @p, $File::Find::name if $_ eq 'index.html' }, '.');
    return sort grep { !m{^\./(?:\.git|herramientas|node_modules)/} } @p;
}

sub leer {
    my ($archivo) = @_;
    open my $fh, '<', $archivo or die "$archivo: $!";
    local $/;
    return scalar <$fh>;
}

my %antes = map { $_ => leer($_) } paginas();
system($^X, 'herramientas/generar.pl') == 0 or die "fallo generar.pl\n";
my @distintas = grep { !exists $antes{$_} || $antes{$_} ne leer($_) } paginas();
if (@distintas) {
    print "Paginas desactualizadas (ya quedaron regeneradas, falta subirlas):\n", map { "  $_\n" } @distintas;
    $errores++;
}

my %usadas;
for my $pagina (paginas()) {
    my $html = leer($pagina);
    $usadas{$1}++ while $html =~ m{assets/img/([^"')\s]+)}g;
    while ($html =~ /(<img\b[^>]*>)/g) {
        next if $1 =~ /\balt="/;
        print "Imagen sin texto alternativo (alt) en $pagina: $1\n";
        $errores++;
    }
    my %vistos;
    while ($html =~ /\b(?:href|src)="([^"]*)"/g) {
        my $url = $1;
        next if $url eq '' || $url =~ /^(?:#|[a-z][a-z0-9+.-]*:)/i;   # anclas y enlaces externos
        $url =~ s/[?#].*//;
        next if $vistos{$url}++;
        my $destino = File::Spec->catfile(dirname($pagina), $url);
        $destino = File::Spec->catfile($destino, 'index.html') if -d $destino;
        next if -e $destino;
        print "Enlace roto en $pagina: $url\n";
        $errores++;
    }
}

# Solo aviso: una imagen sin uso no rompe el sitio, pero pesa en el repositorio.
$usadas{$_}++ for leer('assets/css/estilos.css') =~ m{img/([^"')\s]+)}g;
opendir my $dir, 'assets/img' or die "assets/img: $!";
for my $img (sort grep { !/^\./ } readdir $dir) {
    print "Aviso: assets/img/$img no se usa en ninguna pagina; si sobra, borrala.\n" unless $usadas{$img};
}
closedir $dir;

print $errores ? "Revision con $errores problema(s).\n" : "Revision correcta.\n";
exit($errores ? 1 : 0);
