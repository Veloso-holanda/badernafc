import 'package:firebase_auth/firebase_auth.dart';

class ServicoAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get usuarioAtual => _auth.currentUser;

  static bool get estaLogado => _auth.currentUser != null;

  static Future<String?> obterToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  static Future<UserCredential> cadastrar({
    required String email,
    required String senha,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  static Future<UserCredential> login({
    required String email,
    required String senha,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  static Future<void> sair() async {
    await _auth.signOut();
  }

  static String traduzirErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este email já está cadastrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'Senha muito fraca (mínimo 6 caracteres)';
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou senha incorretos';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'user-disabled':
        return 'Conta desativada';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}
