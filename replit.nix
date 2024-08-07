{pkgs}: {
  deps = [
    pkgs.python311Packages.gtts
    pkgs.ffmpeg-full
    pkgs.firebase-tools
    pkgs.codimd
    pkgs.python311Packages.django_5
    pkgs.python311Packages.clvm-tools
    pkgs.dig
    pkgs.incus
    pkgs.q
  ];
}
