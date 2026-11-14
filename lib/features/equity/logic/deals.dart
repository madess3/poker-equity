/// Сделки по банку: EV chop и страховка от аутов.
library;

class ChopResult {
  ChopResult(this.equity, this.pot, this.feePct);
  final double equity, pot, feePct;
  double get fee => pot * feePct / 100;
  double get share => pot * equity; // доля без сделки
  double get chop => share - fee; // сумма EV chop
  double get feeOfShare => share > 0 ? fee / share : 0; // доля комиссии от доли
}

class InsuranceResult {
  InsuranceResult({
    required this.outs,
    required this.unseen,
    required this.p,
    required this.stake,
    required this.odds,
  });

  final int outs, unseen;
  final double p; // шанс аута
  final double stake; // сумма страховки S
  final double odds; // коэффициент выплаты K

  double get fair =>
      p > 0 ? (1 - p) / p : double.infinity; // честный коэффициент
  double get ev => p * odds * stake - (1 - p) * stake;
  double get overpayPct => stake > 0 ? -ev / stake * 100 : 0;
  double get payout => odds * stake;
}
