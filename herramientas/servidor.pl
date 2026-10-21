#!/usr/bin/perl
# Servidor local para revisar el sitio:  perl herramientas/servidor.pl [puerto]
# Luego abrir http://localhost:8080
use strict;
use warnings;
use HTTP::Daemon;
use HTTP::Status;
use FindBin;

my $puerto = shift // 8080;
my $raiz = "$FindBin::Bin/..";
my %tipos = (html => 'text/html; charset=utf-8', css => 'text/css', js => 'text/javascript',
             png => 'image/png', jpg => 'image/jpeg', jpeg => 'image/jpeg', gif => 'image/gif', svg => 'image/svg+xml');

my $d = HTTP::Daemon->new(LocalAddr => '127.0.0.1', LocalPort => $puerto, ReuseAddr => 1) or die "No se pudo abrir el puerto $puerto\n";
$| = 1;
print "Sitio en http://localhost:$puerto/\n";
while (my $c = $d->accept) {
    while (my $r = $c->get_request) {
        my $ruta = $r->uri->path;
        $ruta =~ s/%([0-9A-Fa-f]{2})/chr(hex $1)/ge;
        $ruta .= 'index.html' if $ruta =~ m{/$};
        if ($ruta =~ /\.\./ || !-f "$raiz$ruta") {
            -d "$raiz$ruta" ? $c->send_redirect("$ruta/") : $c->send_error(RC_NOT_FOUND);
            next;
        }
        my ($ext) = $ruta =~ /\.(\w+)$/;
        open my $fh, '<:raw', "$raiz$ruta" or do { $c->send_error(RC_FORBIDDEN); next };
        local $/;
        my $cuerpo = <$fh>;
        close $fh;
        $c->send_response(HTTP::Response->new(200, 'OK', ['Content-Type' => $tipos{lc($ext // '')} // 'application/octet-stream'], $cuerpo));
    }
    $c->close;
}
