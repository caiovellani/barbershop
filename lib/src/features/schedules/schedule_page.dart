import 'package:barbershop/src/core/ui/barbershop_icons.dart';
import 'package:barbershop/src/core/ui/constants.dart';
import 'package:barbershop/src/core/ui/helpers/form_helper.dart';
import 'package:barbershop/src/core/ui/helpers/messages.dart';
import 'package:barbershop/src/core/ui/widgets/avatar_widget.dart';
import 'package:barbershop/src/core/ui/widgets/hours_panel.dart';
import 'package:barbershop/src/features/schedules/schedule_state.dart';
import 'package:barbershop/src/features/schedules/schedule_vm.dart';
import 'package:barbershop/src/features/schedules/widgets/schedule_calendar.dart';
import 'package:barbershop/src/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:validatorless/validatorless.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  var dateFormat = DateFormat('dd/MM/yyyy');
  var showCalendar = false;
  final formKey = GlobalKey<FormState>();
  final _clienteEC = TextEditingController();
  final _dateEC = TextEditingController();

  @override
  void dispose() {
    _clienteEC.dispose();
    _dateEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ModalRoute.of(context)!.settings.arguments as UserModel;
    final scheduleVM = ref.watch(scheduleVmProvider.notifier);

    final employeeData = switch (userModel) {
      UserModelADM(:final workDays, :final workHours) => (
          workDays: workDays!,
          workHours: workHours!,
        ),
      UserModelEMployee(:final workDays, :final workHours) => (
          workDays: workDays,
          workHours: workHours,
        )
    };

    ref.listen(
      scheduleVmProvider.select((state) => state.status),
      (_, status) {
        switch (status) {
          case ScheduleStateStatus.initial:
            break;
          case ScheduleStateStatus.success:
            Messages.showSuccess('Cliente agendado com sucesso', context);
            Navigator.of(context).pop();
          case ScheduleStateStatus.error:
            Messages.showError('Erro ao registrar agendamento', context);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cliente'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Center(
              child: Column(
                children: [
                  const AvatarWidget(hideUploadButton: true),
                  const SizedBox(height: 24),
                  Text(
                    userModel.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 37),
                  TextFormField(
                    controller: _clienteEC,
                    validator: Validatorless.required('Cliente obrigatório'),
                    decoration: const InputDecoration(
                      label: Text(
                        'Cliente',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _dateEC,
                    validator: Validatorless.required(
                        'Selecione a data do agendamento'),
                    readOnly: true,
                    onTap: () {
                      setState(() {
                        showCalendar = true;
                      });
                      context.unfocus();
                    },
                    decoration: const InputDecoration(
                      label: Text(
                        'Selecione uma data',
                      ),
                      hintText: 'Selecione uma data',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      suffixIcon: Icon(
                        BarbershopIcons.calendar,
                        color: ColorsConstants.brow,
                        size: 18,
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: !showCalendar,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        ScheduleCalendar(
                          cancelPressed: () {
                            setState(() {
                              showCalendar = false;
                            });
                          },
                          okPressed: (DateTime value) {
                            setState(() {
                              _dateEC.text = dateFormat.format(value);
                              scheduleVM.dateSelect(value);
                              showCalendar = false;
                            });
                          },
                          workDays: employeeData.workDays,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  HoursPanel.singleSelection(
                    onHourPressed: scheduleVM.hourSelect,
                    startTime: 8,
                    endTime: 21,
                    enabledTimes: employeeData.workHours,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: () {
                      switch (formKey.currentState?.validate()) {
                        case null || false:
                          Messages.showError('Dados incompletos', context);
                        case true:
                          final hourSelected = ref.watch(
                            scheduleVmProvider.select(
                              (state) => state.scheduleHour != null,
                            ),
                          );
                          if (hourSelected) {
                            scheduleVM.register(
                              userModel: userModel,
                              clientName: _clienteEC.text,
                            );
                          } else {
                            Messages.showError(
                              'Por favor selecione um horário de atendimento',
                              context,
                            );
                          }
                      }
                    },
                    child: const Text('Agendar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
