import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/routes/app_routes.dart';

class CreateCharactersButton extends StatelessWidget {

  const CreateCharactersButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return FloatingActionButton(
        onPressed: () => context.goNamed(AppRouteNames.charactersCreate),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: Icon(Icons.add),
          // child: Icons.add,
        ),
      );
    });
  }
}
