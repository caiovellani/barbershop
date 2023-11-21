import 'package:barbershop/src/core/exceptions/service.exception.dart';
import 'package:barbershop/src/core/fp/either.dart';
import 'package:barbershop/src/core/fp/nil.dart';

abstract interface class UserRegisterAdmService {
  Future<Either<ServiceException, Nil>> execute(
    ({
      String name,
      String email,
      String password,
    }) userData,
  );
}
