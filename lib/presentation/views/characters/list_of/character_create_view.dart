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

  late final void Function() _disposeCharacterEffect;
  late final void Function() _disposeSuccessEffect;
  late final void Function() _disposeErrorEffect;

  late final AccountFormFieldsController _formFields;
  final ScrollController _scrollController = ScrollController();

  var _createdAt = DateTime.now();
  int _level = 1;
  int _attack = 0;
  int _health = 0;
  int _threat = 0;
  int _stars = 1;
  CharacterClass _selectedClass = CharacterClass.poderoso;
  CharacterRarity _selectedRarity = CharacterRarity.prata;
  CharacterAlignment _selectedAlignment = CharacterAlignment.heroi;

  @override
  void initState() {
    super.initState();
    _formFields = AccountFormFieldsController();

    _vmCharacter = injector.get<CharactersViewModel>();
    _vmCharacter.charactersState.clearMessage();
    _vmCharacter.charactersState.clearSuccessEvent();

    _disposeCharacterEffect = effect(() {
      final character = _vmCharacter.charactersState.characterSelected.value;

      if (character != null) {
        _fillFields(character);
      } else {
        _cleanFields();
      }
    });

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
              _finishOperation();
          }

          showSnackBar(context, message, backgroundColor: color);

          _resetFormView();

          _vmCharacter.charactersState.clearSuccessEvent();
        });
      }
    });
  }

  @override
  void dispose() {
    _disposeCharacterEffect();
    _disposeSuccessEffect();
    _disposeErrorEffect();

    _scrollController.dispose();

    _formFields.dispose();
    super.dispose();
  }

  void _fillFields(Character character) {
    _formFields.name.controller.text = character.name;

    _createdAt = character.createdAt;
    _level = character.level;
    _attack = character.attack;
    _health = character.health;
    _threat = character.threat;
    _stars = character.stars;
    _selectedClass = character.characterClass;
    _selectedRarity = character.rarity;
    _selectedAlignment = character.alignment;

    setState(() {});
  }

  void _cleanFields() {
    _formKey.currentState?.reset();
    _formFields.clear();

    _level = 1;
    _attack = 0;
    _health = 0;
    _threat = 0;
    _stars = 1;
    _selectedClass = CharacterClass.poderoso;
    _selectedRarity = CharacterRarity.prata;
    _selectedAlignment = CharacterAlignment.heroi;

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

    final characterSelected =
        _vmCharacter.charactersState.characterSelected.value;

    Character newCharacter = Character(
      id: characterSelected != null
          ? characterSelected.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _formFields.name.controller.text.trim(),
      createdAt: _createdAt,
      level: _level,
      attack: _attack,
      health: _health,
      threat: _threat,
      stars: _stars,
      characterClass: _selectedClass,
      rarity: _selectedRarity,
      alignment: _selectedAlignment,
      updatedAt: characterSelected != null ? DateTime.now() : _createdAt,
    );

    if (_vmCharacter.charactersState.characterSelected.value == null) {
      _vmCharacter.commands.addCharacter(newCharacter);
    } else {
      _vmCharacter.commands.updateCharacter(newCharacter);
    }
  }

  void _finishOperation() {
    _vmCharacter.charactersState.characterSelected.value = null;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_vmCharacter.charactersState.pageTitle.value)),
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
                  value: _selectedClass,
                  onChanged: (v) => setState(() => _selectedClass = v),
                  labelBuilder: (c) => c.displayName,
                  colorBuilder: (c) => c.color,
                ),
                const SizedBox(height: AppSpacing.md),

                CharacterSelect<CharacterRarity>(
                  title: 'Raridade',
                  items: CharacterRarity.values,
                  value: _selectedRarity,
                  onChanged: (v) => setState(() => _selectedRarity = v),
                  labelBuilder: (r) => r.displayName,
                  colorBuilder: (r) => r.color,
                ),
                const SizedBox(height: AppSpacing.sm),

                CharacterSelect<CharacterAlignment>(
                  title: 'Caráter',
                  items: CharacterAlignment.values,
                  value: _selectedAlignment,
                  onChanged: (v) => setState(() => _selectedAlignment = v),
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
                    Watch((context) {
                      final isEditing =
                          _vmCharacter.charactersState.characterSelected.value;

                      final isRunning =
                          _vmCharacter
                              .commands
                              .createCharacterCommand
                              .isExecuting
                              .value ||
                          _vmCharacter
                              .commands
                              .updateCharacterCommand
                              .isExecuting
                              .value;
                      return ElevatedButton(
                        onPressed: isRunning ? null : _saveCharacter,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),

                        child: isRunning
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _vmCharacter.charactersState.labelEditMode.value,
                                style: context.textStyles.titleMedium?.bold,
                              ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.md),

                    OutlinedButton(
                      onPressed: () => _finishOperation(),
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
