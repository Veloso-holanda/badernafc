import 'membro.dart';
import 'time.dart';

class ContextoTime {
  static String? timeIdAtivo;
  static String? papelNoTime;
  static Membro? membroAtual;
  static Time? timeAtivo;

  static bool get ehAdmin => papelNoTime == 'admin';

  static String? get jogadorIdAtual => membroAtual?.jogadorId;

  static void definir({
    required Time time,
    required Membro membro,
  }) {
    timeIdAtivo = time.id;
    timeAtivo = time;
    papelNoTime = membro.papel;
    membroAtual = membro;
  }

  static void limpar() {
    timeIdAtivo = null;
    papelNoTime = null;
    membroAtual = null;
    timeAtivo = null;
  }
}
