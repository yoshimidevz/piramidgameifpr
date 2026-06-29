import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Permite arrastar com o mouse para rolar (Flutter bloqueia isso por
// padrao no Chrome/desktop, pensando em nao conflitar com selecao de
// texto). Util durante o desenvolvimento/teste no navegador - em
// dispositivos moveis reais (touch), o scroll ja funciona normalmente
// sem essa customizacao.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}