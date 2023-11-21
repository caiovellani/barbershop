import 'package:barbershop/src/core/ui/helpers/form_helper.dart';
import 'package:barbershop/src/core/ui/helpers/messages.dart';
import 'package:barbershop/src/features/register/user/user_register_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';

class UserRegisterPage extends ConsumerStatefulWidget {
  const UserRegisterPage({super.key});

  @override
  ConsumerState<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends ConsumerState<UserRegisterPage> {
  final formKey = GlobalKey<FormState>();
  final _emailEC = TextEditingController();
  final _passwordEC = TextEditingController();
  final _nameEC = TextEditingController();

  @override
  void dispose() {
    _emailEC.dispose();
    _passwordEC.dispose();
    _nameEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRegisterVM = ref.watch(userRegisterVmProvider.notifier);

    ref.listen(userRegisterVmProvider, (_, state) {
      switch (state) {
        case UserRegisterStateStatus.initial:
          break;
        case UserRegisterStateStatus.success:
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/auth/register/barbershop', (route) => false);
          break;
        case UserRegisterStateStatus.error:
          Messages.showError(
            'Erro ao registrar usuário administrador',
            context,
          );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  onTapOutside: (_) => context.unfocus(),
                  controller: _nameEC,
                  validator: Validatorless.required('Nome Obrigatório'),
                  decoration: const InputDecoration(
                    label: Text('Nome'),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  onTapOutside: (_) => context.unfocus(),
                  controller: _emailEC,
                  validator: Validatorless.multiple([
                    Validatorless.required('Email obrigatorio'),
                    Validatorless.email('Email inválido'),
                  ]),
                  decoration: const InputDecoration(
                    label: Text('Email'),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  onTapOutside: (_) => context.unfocus(),
                  obscureText: true,
                  controller: _passwordEC,
                  validator: Validatorless.multiple([
                    Validatorless.required('Senha obrigatória'),
                    Validatorless.min(
                        6, 'Senha deve conter pelo menos 6 caracteres'),
                  ]),
                  decoration: const InputDecoration(
                    label: Text('Senha'),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  onTapOutside: (_) => context.unfocus(),
                  obscureText: true,
                  validator: Validatorless.multiple([
                    Validatorless.required('Confirmar senha obrigatória'),
                    Validatorless.min(6,
                        'Confirmar senha deve conter pelo menos 6 caracteres'),
                    Validatorless.compare(
                        _passwordEC, 'As senhas devem ser iguais'),
                  ]),
                  decoration: const InputDecoration(
                    label: Text('Confirmar senha'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () {
                    switch (formKey.currentState?.validate()) {
                      case null || false:
                        Messages.showError('Campos inválidos', context);
                      case true:
                        userRegisterVM.register(
                          name: _nameEC.text,
                          email: _emailEC.text,
                          password: _passwordEC.text,
                        );
                    }
                  },
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
