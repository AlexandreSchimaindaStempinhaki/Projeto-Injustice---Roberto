import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injustice_app/core/routes/app_routes.dart';
import 'package:injustice_app/core/theme/app_theme.dart';
import 'package:injustice_app/core/validators/max_lenght_str_validator%20copy.dart';
import 'package:injustice_app/core/validators/min_lenght_str_validator.dart';
import 'package:injustice_app/presentation/controllers/characters_view_model.dart';
import 'package:injustice_app/presentation/views/characters/list_of/widgets/character_star_selector.dart';
import 'package:injustice_app/presentation/widgets/app_drawer.dart';
import '../../../../../core/validators/empty_str_validator.dart';
import '../../account_create_view.dart';
import '../../../widgets/input_text_field.dart';
import '../../../functions/ui_functions.dart';
import '../../../widgets/account_attribute_card.dart';
import 'widgets/character_select.dart';
import '../../../../domain/models/character_entity.dart';
import '../../../../../domain/models/extensions/character_ui.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../domain/models/account_entity.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../controllers/characters_state_viewmodel.dart';
import '../../../../core/typedefs/types_defs.dart';

class CharacterCreateView extends StatefulWidget {
  const CharacterCreateView({super.key});

  @override
  State<CharacterCreateView> createState() => _CharacterCreateViewState();
}

class _CharacterCreateViewState extends State<CharacterCreateView> {
  final _formKey = GlobalKey<FormState>();

  late final CharactersViewModel _vmCharacter;

  late final void Function() _disposeSuccessEffect;
  late final void Function() _disposeErrorEffect;

  late final AccountFormFieldsController _formFields;
  final ScrollController _scrollController = ScrollController();

  final _createdAt = DateTime.now();
  int _level = 1;
  int _attack = 0;
  int _health = 0;
  int _threat = 0;
  int _stars = 1;
  CharacterClass selectedClass = CharacterClass.poderoso;
  CharacterRarity selectedRarity = CharacterRarity.prata;
  CharacterAlignment selectedAlignment = CharacterAlignment.heroi;

  @override
  void initState() {
    super.initState();
    _formFields = AccountFormFieldsController();

    _vmCharacter = injector.get<CharactersViewModel>();
    _vmCharacter.charactersState.clearMessage();
    _vmCharacter.charactersState.clearSuccessEvent();

    _disposeErrorEffect = effect(() {
      final errorMessage = _vmCharacter.charactersState.message.value;

      if (errorMessage != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          showSnackBar(context, errorMessage, backgroundColor: Colors.red);

          _vmCharacter.charactersState.clearMessage();
        });
      }
    });
    
    _disposeSuccessEffect = effect(() {
      final event = _vmCharacter.charactersState.successEvent.value;

      if (event != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          String message;
          Color color;

          switch (event) {
            case CharacterSuccessEvent.created:
              message = 'Personagem criado com sucesso!';
              color = Colors.green;

            case CharacterSuccessEvent.updated:
              message = 'Personagem atualizado com sucesso!';
              color = Colors.green;
          }

          showSnackBar(context, message, backgroundColor: color);

          _vmCharacter.charactersState.clearSuccessEvent();
        });
      }
    });
  }

  @override
  void dispose() {
    // _disposeAccountEffect();
    _disposeSuccessEffect();
    _disposeErrorEffect();

    _scrollController.dispose();

    _formFields.dispose();
    super.dispose();
  }

  void _cleanFields() {
    _formKey.currentState?.reset();
    _formFields.clear();

    _level = 1;
    _attack = 0;
    _health = 0;
    _threat = 0;
    _stars = 1;
    selectedClass = CharacterClass.poderoso;
    selectedRarity = CharacterRarity.prata;
    selectedAlignment = CharacterAlignment.heroi;

    setState(() {});
  }

  void _resetFormView() {
    // Remove foco de qualquer TextField
    FocusScope.of(context).unfocus();

    // Rola para o topo
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _cleanFields();
  }

  void _focusFirstError() {
    for (final field in _formFields.fields) {
      final state = field.key.currentState;

      if (state != null && !state.isValid) {
        field.focus.requestFocus();

        Scrollable.ensureVisible(
          field.key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );

        break;
      }
    }
  }

  bool _validateForm() {
    final valid = _formKey.currentState!.validate();

    if (!valid) {
      _focusFirstError();
    }

    return valid;
  }

  void _saveCharacter() {
    if (!_validateForm()) return;

    Character newCharacter = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _formFields.name.controller.text.trim(),
      createdAt: _createdAt,
      level: _level,
      attack: _attack,
      health: _health,
      threat: _threat,
      stars: _stars,
      characterClass: selectedClass,
      rarity: selectedRarity,
      alignment: selectedAlignment,
      updatedAt: _createdAt,
    );

    _vmCharacter.commands.addCharacter(newCharacter);

    _resetFormView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Personagem')),
      drawer: AppDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.person_add,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Preencha os dados para criar um novo personagem',
                  style: context.textStyles.bodyMedium?.withColor(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                InputTextField(
                  fieldKey: _formFields.name.key,
                  controller: _formFields.name.controller,
                  focusNode: _formFields.name.focus,
                  prefixIcon: Icons.account_circle,
                  label: 'Nome',
                  hint: 'Digite o nome do seu personagem',
                  validator: (value) => validateField(value, [
                    EmptyStrValidator(),
                    MinLengthStrValidator(minLength: 3),
                    MaxLengthStrValidator(maxLength: 20),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),

                AccountAttributeCard(
                  icon: Icons.star,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Nível',
                  hint: '[1, 80]',
                  minValue: 1,
                  maxValue: 80,
                  value: _level,
                  onChanged: (value) => setState(() => _level = value),
                ),
                const SizedBox(height: AppSpacing.md),

                AccountAttributeCard(
                  icon: Icons.local_fire_department,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Ataque',
                  hint: '[0, 100]',
                  minValue: 0,
                  maxValue: 100,
                  value: _attack,
                  onChanged: (value) => setState(() => _attack = value),
                ),
                const SizedBox(height: AppSpacing.md),

                AccountAttributeCard(
                  icon: Icons.favorite,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Vida',
                  hint: '[0, 100]',
                  minValue: 0,
                  maxValue: 100,
                  value: _health,
                  onChanged: (value) => setState(() => _health = value),
                ),
                const SizedBox(height: AppSpacing.md),

                AccountAttributeCard(
                  icon: Icons.dangerous,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Ameaça',
                  hint: '[0, 100]',
                  minValue: 0,
                  maxValue: 100,
                  value: _threat,
                  onChanged: (value) => setState(() => _threat = value),
                ),
                const SizedBox(height: AppSpacing.md),

                CharacterSelect<CharacterClass>(
                  title: 'Classe',
                  items: CharacterClass.values,
                  value: selectedClass,
                  onChanged: (v) => setState(() => selectedClass = v),
                  labelBuilder: (c) => c.displayName,
                  colorBuilder: (c) => c.color,
                ),
                const SizedBox(height: AppSpacing.md),

                CharacterSelect<CharacterRarity>(
                  title: 'Raridade',
                  items: CharacterRarity.values,
                  value: selectedRarity,
                  onChanged: (v) => setState(() => selectedRarity = v),
                  labelBuilder: (r) => r.displayName,
                  colorBuilder: (r) => r.color,
                ),
                const SizedBox(height: AppSpacing.sm),

                CharacterSelect<CharacterAlignment>(
                  title: 'Caráter',
                  items: CharacterAlignment.values,
                  value: selectedAlignment,
                  onChanged: (v) => setState(() => selectedAlignment = v),
                  labelBuilder: (a) => a.displayName,
                  colorBuilder: (a) => a.color,
                ),
                const SizedBox(height: AppSpacing.sm),

                StarSelector(
                  value: _stars,
                  onChanged: (v) => setState(() => _stars = v),
                ),
                const SizedBox(height: AppSpacing.sm),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _saveCharacter,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(
                        'CRIAR',
                        style: context.textStyles.titleMedium?.bold,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(
                        'VOLTAR',
                        style: context.textStyles.titleMedium?.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
