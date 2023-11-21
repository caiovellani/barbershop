import 'package:asyncstate/asyncstate.dart';
import 'package:barbershop/src/core/exceptions/service.exception.dart';
import 'package:barbershop/src/core/fp/either.dart';
import 'package:barbershop/src/core/providers/application_providers.dart';
import 'package:barbershop/src/features/auth/login/login_state.dart';
import 'package:barbershop/src/model/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_vm.g.dart';

@riverpod
class LoginVm extends _$LoginVm {
  @override
  LoginState build() => LoginState.initial();

  Future<void> login(String email, String password) async {
    final loaderHandle = AsyncLoaderHandler()..start();
    final loginService = ref.watch(userLoginServiceProvider);
    final result = await loginService.execute(email, password);

    switch (result) {
      case Success():
        // Invalidando os caches para evitar o Login com o usuário errado!
        ref.invalidate(getMeProvider);
        ref.invalidate(getMyBarbershopProvider);

        // Buscar dados do usuário logado;
        // Fazer uma ánalise para qual o tipo de Login(ADM, ou, EMPLOYER);
        final userModel = await ref.read(getMeProvider.future);
        switch (userModel) {
          case UserModelADM():
            state = state.copyWith(status: LoginStateStatus.admLogin);
          case UserModelEMployee():
            state = state.copyWith(status: LoginStateStatus.employeeLogin);
        }
        break;
      case Failure(
          exception: ServiceException(:final message)
        ): // Destruction Dart 3
        state = state.copyWith(
          status: LoginStateStatus.error,
          errorMessage: () => message,
        );
    }
    loaderHandle.close();
  }
}
