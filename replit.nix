{pkgs}: {
  deps = [
    pkgs.python311Packages.clvm-tools
    pkgs.dig
    pkgs.incus
    pkgs.q
  ];
}
