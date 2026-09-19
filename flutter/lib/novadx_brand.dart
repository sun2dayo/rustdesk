// NovaDX: elementos de marca do cliente (cabeçalho, textos, contactos, cores).
// Mantido num ficheiro próprio para as alterações aos ficheiros da RustDesk
// serem mínimas e as atualizações do fork continuarem simples.

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

const Color kNovadxBlue = Color(0xFF0F63B8);
const Color kNovadxBlueLight = Color(0xFFCFE0F5);
const Color kNovadxOrange = Color(0xFFDF820A);

const String kNovadxSite = 'https://novadx.pt';
const String kNovadxSiteLabel = 'novadx.pt';
const String kNovadxPhone = '+351 963 464 645';
const String kNovadxPhoneUri = 'tel:+351963464645';
const String kNovadxWhatsAppUri = 'https://wa.me/351963464645';
const List<String> kNovadxEmails = ['ola@novadx.pt', 'sol@solisys.com'];

const String kNovadxReady = 'Ligado ao servidor NovaDX';

/// Variante embutida na compilação: suporte | agente | tecnico ('' fora do fork NovaDX).
String novadxVariant() => bind.mainGetHardOption(key: 'novadx-variant');

bool isNovadxClient() => novadxVariant().isNotEmpty;

bool isNovadxAgent() => novadxVariant() == 'agente';

String novadxWelcomeText() => isNovadxAgent()
    ? 'Este posto é gerido pela NovaDX. A assistência remota está ativa.'
    : 'Olá. Indique ao técnico NovaDX o ID e a senha abaixo.';

void _open(String url) {
  canLaunchUrlString(url).then((can) {
    if (can) launchUrlString(url);
  });
}

/// Faixa azul no topo da janela principal: símbolo + "NovaDX / Assistência Remota".
Widget novadxHeader(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: Container(
      color: kNovadxBlue,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: loadIcon(24),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('NovaDX',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2)),
              Text('Assistência Remota',
                  style: TextStyle(color: kNovadxBlueLight, fontSize: 12)),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _contactLine(BuildContext context, IconData icon, String text,
    {String? url}) {
  final color = Theme.of(context).textTheme.bodySmall?.color;
  final line = Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Flexible(
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12,
                color: color,
                decoration:
                    url == null ? TextDecoration.none : TextDecoration.underline)),
      ),
    ],
  ).paddingSymmetric(vertical: 2);
  if (url == null) return line;
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(onTap: () => _open(url), child: line),
  );
}

/// Rodapé com contactos clicáveis e filete laranja de marca.
Widget novadxFooter(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kNovadxOrange, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _contactLine(context, Icons.phone, '$kNovadxPhone (tel. e WhatsApp)',
              url: kNovadxPhoneUri),
          _contactLine(context, Icons.chat_outlined, 'WhatsApp NovaDX',
              url: kNovadxWhatsAppUri),
          for (final email in kNovadxEmails)
            _contactLine(context, Icons.mail_outline, email,
                url: 'mailto:$email'),
          _contactLine(context, Icons.language, kNovadxSiteLabel,
              url: kNovadxSite),
        ],
      ),
    ),
  );
}

/// Faixa no topo da janela de sessão que o cliente vê enquanto o técnico está ligado.
Widget novadxSessionBanner(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kNovadxBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: const [
          Icon(Icons.lock_outline, size: 16, color: Colors.white),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Sessão de assistência NovaDX em curso. Pode terminar a qualquer momento.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Bloco "Sobre" do NovaDX: links NovaDX + aviso legal obrigatório (AGPL-3.0).
List<Widget> novadxAboutLinks() {
  const linkStyle = TextStyle(decoration: TextDecoration.underline);
  return [
    InkWell(
        onTap: () => _open(kNovadxSite),
        child: const Text('NovaDX — $kNovadxSiteLabel', style: linkStyle)
            .marginSymmetric(vertical: 4.0)),
    InkWell(
        onTap: () => _open('mailto:${kNovadxEmails.first}'),
        child: Text(kNovadxEmails.first, style: linkStyle)
            .marginSymmetric(vertical: 4.0)),
  ];
}

String novadxLegalNotice(String license) =>
    'NovaDX Assistência Remota © ${DateTime.now().year} NovaDX\n'
    'Baseado em RustDesk © Purslane Tech Pte. Ltd. — AGPL-3.0\n'
    'Código-fonte: https://github.com/sun2dayo/rustdesk\n$license';
