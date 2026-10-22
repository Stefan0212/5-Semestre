import 'package:flutter/material.dart';

void main() {
  runApp(const ParticipanteApp());
}

class ParticipanteApp extends StatelessWidget {
  const ParticipanteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de Participante',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 35, 235)),
        useMaterial3: true,
      ),
      home: const TelaCadastro(),
    );
  }
}

// Representa os dados preenchidos no formulário.
class Participante {
  final String email;
  final String nome;
  final String telefone;
  final String cpf;

  const Participante({
    required this.email,
    required this.nome,
    required this.telefone,
    required this.cpf,
  });
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();

  // Validador de E-mail
  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) {
      return 'Informe o e-mail.';
    }
    final formato = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!formato.hasMatch(email)) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  // Validador de Nome
  String? _validarNome(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) {
      return 'Informe o nome.';
    }
    if (nome.length < 3) {
      return 'O nome deve ter pelo menos três caracteres.';
    }
    return null;
  }

  // Validador de Telefone
  String? _validarTelefone(String? valor) {
    final telefone = valor?.trim() ?? '';
    if (telefone.isEmpty) {
      return 'Informe o telefone.';
    }
    final formato = RegExp(r'^\d{2}-\d{5}-\d{4}$');
    if (!formato.hasMatch(telefone)) {
      return 'Informe um telefone no formato DD-DDDDD-DDDD.';
    }
    return null;
  }

  // Validador de CPF
  String? _validarCpf(String? valor) {
    final cpf = valor?.trim() ?? '';
    if (cpf.isEmpty) {
      return 'Informe o CPF.';
    }
    final formato = RegExp(r'^\d{11}$');
    if (!formato.hasMatch(cpf)) {
      return 'O CPF deve conter exatamente 11 dígitos numéricos.';
    }
    return null;
  }

  void _exibirDados() {
    final formularioValido = _formKey.currentState!.validate();
    if (!formularioValido) {
      return;
    }

    final participante = Participante(
      email: _emailController.text.trim(),
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      cpf: _cpfController.text.trim(),
    );

    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => TelaResumo(participante: participante),
      ),
    );
  }

  void _limpar() {
    _formKey.currentState!.reset();
    _emailController.clear();
    _nomeController.clear();
    _telefoneController.clear();
    _cpfController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Participante'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Informe os dados do participante.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'Ex.: ana@email.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                validator: _validarEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Ana Souza',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: _validarNome,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'DD-DDDDD-DDDD',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: _validarTelefone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: 'Ex.: 12345678901 (Apenas números)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: _validarCpf,
                onFieldSubmitted: (_) => _exibirDados(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _exibirDados,
                child: const Text('Exibir dados'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _limpar,
                child: const Text('Limpar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaResumo extends StatelessWidget {
  final Participante participante;

  const TelaResumo({
    super.key,
    required this.participante,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo do cadastro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dados do participante',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text('E-mail: ${participante.email}'),
            const SizedBox(height: 12),
            Text('Nome: ${participante.nome}'),
            const SizedBox(height: 12),
            Text('Telefone: ${participante.telefone}'),
            const SizedBox(height: 12),
            Text('CPF: ${participante.cpf}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar para editar'),
            ),
          ],
        ),
      ),
    );
  }
}