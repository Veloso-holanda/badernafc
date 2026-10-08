// Testes de widget para o ajuste de design system do BAD-61:
// centralização do toggle de visibilidade de senha no AppTextField e seu
// uso nas telas de Login e Cadastro.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:badernafc/shared/shared.dart';
import 'package:badernafc/usuarios/telas/tela_login.dart';
import 'package:badernafc/usuarios/telas/tela_cadastro.dart';

/// Lê o estado real de obscurecimento do campo (via EditableText interno).
bool _campoObscurecido(WidgetTester tester) {
  final editable = tester.widget<EditableText>(find.byType(EditableText));
  return editable.obscureText;
}

void main() {
  group('AppTextField — campo obscurável', () {
    testWidgets('inicia obscurecido e exibe o ícone de revelar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(label: 'Senha', obscuravel: true),
          ),
        ),
      );

      expect(_campoObscurecido(tester), isTrue);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('alterna a visibilidade ao tocar no ícone', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(label: 'Senha', obscuravel: true),
          ),
        ),
      );

      // Revela a senha.
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(_campoObscurecido(tester), isFalse);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Oculta novamente.
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(_campoObscurecido(tester), isTrue);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('sem obscuravel mantém o comportamento antigo (suffixIcon)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Email',
              suffixIcon: Icon(Icons.check),
            ),
          ),
        ),
      );

      expect(_campoObscurecido(tester), isFalse);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });
  });

  group('TelaLogin — senha', () {
    testWidgets('campo de senha usa o toggle centralizado', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TelaLogin()));
      await tester.pump();

      // Um único campo de senha → um único ícone de visibilidade.
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });
  });

  group('TelaCadastro — senha e confirmação', () {
    testWidgets('os dois campos de senha alternam de forma independente',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TelaCadastro()));
      await tester.pump();

      // Senha + Confirmar senha → dois ícones de visibilidade.
      expect(find.byIcon(Icons.visibility), findsNWidgets(2));

      // Alterna apenas o primeiro.
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
