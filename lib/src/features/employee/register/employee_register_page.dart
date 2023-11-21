import 'dart:developer';

import 'package:barbershop/src/core/providers/application_providers.dart';
import 'package:barbershop/src/core/ui/helpers/messages.dart';
import 'package:barbershop/src/core/ui/widgets/avatar_widget.dart';
import 'package:barbershop/src/core/ui/widgets/barbershop_loader.dart';
import 'package:barbershop/src/core/ui/widgets/hours_panel.dart';
import 'package:barbershop/src/core/ui/widgets/weekdays_panel.dart';
import 'package:barbershop/src/features/employee/register/employee_register_state.dart';
import 'package:barbershop/src/features/employee/register/employee_register_vm.dart';
import 'package:barbershop/src/model/barbershop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';

class EmployeeRegisterPage extends ConsumerStatefulWidget {
  const EmployeeRegisterPage({super.key});

  @override
  ConsumerState<EmployeeRegisterPage> createState() =>
      _EmployeeRegisterPageState();
}

class _EmployeeRegisterPageState extends ConsumerState<EmployeeRegisterPage> {
  var registerADM = false;
  final formKey = GlobalKey<FormState>();
  final _nameEC = TextEditingController();
  final _emailEC = TextEditingController();
  final _passwordEC = TextEditingController();

  @override
  void dispose() {
    _emailEC.dispose();
    _nameEC.dispose();
    _passwordEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeRegisterVM = ref.watch(employeeRegisterVmProvider.notifier);
    final barbershopAsyncValue = ref.watch(getMyBarbershopProvider);

    ref.listen(employeeRegisterVmProvider.select((state) => state.status),
        (_, status) {
      switch (status) {
        case EmployeeRegisterStateStatus.initial:
          break;
        case EmployeeRegisterStateStatus.success:
          Messages.showSuccess('Colaborador cadastrado', context);
          Navigator.of(context).pop();
        case EmployeeRegisterStateStatus.error:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Colaborados'),
      ),
      body: barbershopAsyncValue.when(
        data: (barbershopModel) {
          final BarbershopModel(:openingDays, :openingHours) = barbershopModel;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: formKey,
                child: Center(
                  child: Column(
                    children: [
                      const AvatarWidget(),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Checkbox.adaptive(
                              value: registerADM,
                              onChanged: (value) {
                                setState(() {
                                  registerADM = !registerADM;
                                  employeeRegisterVM
                                      .setRegisterADM(registerADM);
                                });
                              }),
                          const Expanded(
                            child: Text(
                              'Sou administrador e quero me cadastrar como colaborador',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Offstage(
                        offstage: registerADM,
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameEC,
                              validator: registerADM
                                  ? null
                                  : Validatorless.required('Nome obrigatório'),
                              decoration:
                                  const InputDecoration(label: Text('Nome')),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailEC,
                              validator: registerADM
                                  ? null
                                  : Validatorless.multiple([
                                      Validatorless.required(
                                          'Email obrigatório'),
                                      Validatorless.email('Email inválido'),
                                    ]),
                              decoration:
                                  const InputDecoration(label: Text('Email')),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _passwordEC,
                              obscureText: true,
                              validator: registerADM
                                  ? null
                                  : Validatorless.multiple([
                                      Validatorless.required(
                                          'Senha obrigatória'),
                                      Validatorless.min(6,
                                          'Senha deve conter pelo menos 6 caracteres'),
                                    ]),
                              decoration:
                                  const InputDecoration(label: Text('Senha')),
                            ),
                          ],
                        ),
                      ),
                      WeekdaysPanel(
                        enabledDays: openingDays,
                        onDayPressed: employeeRegisterVM.addOrRemoveWorkdays,
                      ),
                      const SizedBox(height: 24),
                      HoursPanel(
                        enabledTimes: openingHours,
                        startTime: 8,
                        endTime: 22,
                        onHourPressed: employeeRegisterVM.addOrRemoveWorkhours,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        onPressed: () {
                          switch (formKey.currentState?.validate()) {
                            case false || null:
                              Messages.showError(
                                  'Existem campos inválidos', context);
                            case true:
                              final EmployeeRegisterState(
                                workdays: List(isNotEmpty: hasWorkDays),
                                workhours: List(isNotEmpty: hasWorkHours),
                              ) = ref.watch(employeeRegisterVmProvider);
                              if (!hasWorkDays || !hasWorkHours) {
                                Messages.showError(
                                    'Por favor, selecione pelo menos um dia e hora',
                                    context);
                                return;
                              }
                              final name = _nameEC.text;
                              final email = _emailEC.text;
                              final password = _passwordEC.text;
                              employeeRegisterVM.register(
                                name: name,
                                email: email,
                                password: password,
                              );
                          }
                        },
                        child: const Text('Cadastrar Colaborador'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          log('Erro ao carregar a página',
              error: error, stackTrace: stackTrace);
          return const Center(
            child: Text('Erro ao carregar a página'),
          );
        },
        loading: () => const BarbershopLoader(),
      ),
    );
  }
}
