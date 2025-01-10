{
  lib,
  stdenv,
  fetchFromGitLab,
  xmlto,
  pkg-config,
  alsa-lib,
  docbook_xml_dtd_412,
  xorg,
  useX11 ? stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "morse-classic";
  version = "2.6";
  src = fetchFromGitLab {
    owner = "esr";
    repo = "morse-classic";
    tag = finalAttrs.version;
    hash = "sha256-wk/Jcp2YWUlecV3OMELD6IWrlj3IC8kh0U4geMxG4fw=";
  };

  # https://gitlab.com/esr/morse-classic/-/merge_requests/1
  postPatch = lib.optional useX11 ''
    sed -i "1i#include <time.h>" ./morse.d/alarm.h
  '';

  nativeBuildInputs = [
    xmlto
    pkg-config
  ];

  buildInputs = [
    docbook_xml_dtd_412
  ] ++ (if useX11 then [ xorg.libX11 ] else [ alsa-lib ]);

  buildFlags = lib.optional useX11 "DEVICE=X11";

  preInstall = ''
    mkdir -vp "$out/bin" "$out/share/man/man1"
  '';

  installPhase = ''
    runHook preInstall
    cp ./morse $out/bin
    cp ./QSO $out/bin
    runHook postInstall
  '';

  postInstall = ''
    cp ./morse.1 $out/share/man/man1
    cp ./QSO.1 $out/share/man/man1
  '';

  # This is because the tests need to access system sound in an isolated environment
  doCheck = false;

  meta = {
    description = "A morse-code training program and QSO generator";
    longDescription = ''
      This is Morse Classic, a generic morse-code practice utility for Unix systems.
      You'll invoke it as "morse"; the full name is to distinguish it from Alan
      Cox's "morse" program.
    '';
    license = lib.licenses.bsd2;
    mainProgram = "morse";
    homepage = "http://www.catb.org/~esr/morse/";
    changelog = "https://gitlab.com/esr/morse-classic/-/blob/${finalAttrs.version}/NEWS";
    maintainers = with lib.maintainers; [ EmanuelM153 ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
