import 'package:flutter/material.dart';
import 'package:injustice_app/core/theme/app_theme.dart';
import 'package:injustice_app/presentation/controllers/characters_view_model.dart';
import 'package:injustice_app/presentation/views/characters/list_of/widgets/character_star_selector.dart';
import 'package:injustice_app/presentation/widgets/app_drawer.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/typedefs/types_defs.dart';
import '../../../../../core/validators/email_str_validator.dart';
import '../../../../../core/validators/empty_str_validator.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../account_create_view.dart';
import '../../../widgets/input_text_field.dart';
import '../../../functions/ui_functions.dart';
import '../../../widgets/account_attribute_card.dart';
import 'widgets/character_select.dart';
import '../../../../domain/models/character_entity.dart';
import '../../../../../domain/models/extensions/character_ui.dart';

class CharacterCreateView extends StatefulWidget {
  const CharacterCreateView({super.key});

  @override
  State<CharacterCreateView> createState() => _CharacterCreateViewState();
}

class _CharacterCreateViewState extends State<CharacterCreateView> {
  late final CharactersViewModel _vmCharacter;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  late final AccountFormFieldsController _formFields;

  DateTime _createdAt = DateTime.now();
  int _level = 1;
  int _attack = 1;
  int _health = 1;
  int _threat = 1;
  int _stars = 1;
  CharacterClass selectedClass = CharacterClass.poderoso;
  CharacterRarity selectedRarity = CharacterRarity.prata;
  CharacterAlignment selectedAlignment = CharacterAlignment.heroi;

  @override
  void initState() {
    super.initState();
    _formFields = AccountFormFieldsController();
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
                  validator: (value) =>
                      validateField(value, [EmptyStrValidator()]),
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
                  hint: '[1, 100]',
                  minValue: 1,
                  maxValue: 100,
                  value: _attack,
                  onChanged: (value) => setState(() => _attack = value),
                ),
                const SizedBox(height: AppSpacing.md),

                AccountAttributeCard(
                  icon: Icons.favorite,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Vida',
                  hint: '[1, 100]',
                  minValue: 1,
                  maxValue: 100,
                  value: _health,
                  onChanged: (value) => setState(() => _health = value),
                ),
                const SizedBox(height: AppSpacing.md),

                AccountAttributeCard(
                  icon: Icons.dangerous,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Ameaça',
                  hint: '[1, 100]',
                  minValue: 1,
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

                Row(
                  children: [
                    /// BOTÃO SALVAR / EDITAR
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        child: Text(
                          'SALVAR',
                          style: context.textStyles.titleMedium?.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    /// BOTÃO EXCLUIR
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.tertiary,
                        ),
                        child: Text(
                          'EXCLUIR',
                          style: context.textStyles.titleMedium?.bold,
                        ),
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
