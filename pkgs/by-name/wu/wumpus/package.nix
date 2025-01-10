{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoctor,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wumpus";
  version = "1.10";
  src = fetchFromGitLab {
    owner = "esr";
    repo = "wumpus";
    tag = finalAttrs.version;
    hash = "sha256-rsKcDyr1uYCq/VGjt34/4+BM5bLYrqMTn1UbrWUA5Yo=";
  };

  nativeBuildInputs = [
    asciidoctor
  ];

  postBuild = ''
    make wumpus.6
  '';

  preInstall = ''
    mkdir -vp "$out/bin" "$out/share/man/man6" "$out/share/applications" "$out/share/icons/hicolor/128x128/apps"
  '';

  installPhase = ''
    runHook preInstall
    cp ./wumpus $out/bin
    cp ./superhack $out/bin
    runHook postInstall
  '';

  postInstall = ''
    cp ./wumpus.6 $out/share/man/man6
    cp ./wumpus.desktop $out/share/applications
    cp ./superhack.desktop $out/share/applications
    cp ./wumpus.png $out/share/icons/hicolor/128x128/apps
  '';

  meta = {
    description = "Exact clone of the ancient BASIC Hunt the Wumpus game";
    longDescription = ''
      WUMPUS is a bit of retrocomputing nostalgia.  It is an exact clone,
      even down to the godawful user interface, of an ancient classic game.
    '';
    license = lib.licenses.bsd2;
    mainProgram = "wumpus";
    homepage = "http://www.catb.org/~esr/wumpus/";
    changelog = "https://gitlab.com/esr/wumpus/-/blob/${finalAttrs.version}/NEWS.adoc";
    maintainers = with lib.maintainers; [ EmanuelM153 ];
    platforms = lib.platforms.all;
  };
})
