import 'dart:convert';

import '../../core/failure/failure.dart';
import '../../core/typedefs/types_defs.dart';
import 'character_local_storage_interface.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/patterns/result.dart';

final class CharacterSharedPreferencesService
    implements ICharacterLocalStorage {
  // Chave de armazenamento para os personagens
  static const String _storageKey = 'characters';

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    try {
        final result = await getAllCharacters();

        return await result.fold(
          onSuccess: (characters) async {

            final indexDeletedCharacter = characters.indexWhere((c) => c.id == id);

            if(indexDeletedCharacter == -1) {
              return Error(ApiLocalFailure('Shared Preferences: Personagem não encontrado, id: $id'));
            }
            
            final characterDeleted = characters[indexDeletedCharacter];

            final updatedList = characters.where((c) => c.id != id).toList();
            await _saveCharacters(updatedList);

            return Success(characterDeleted);
          },

          onFailure: (failure) async {
              if(failure is EmptyResultFailure){
                return Error(ApiLocalFailure(
                  'Shared Preferences: Nenhum personagem para deletar!',
                ));
              }
              return Error(failure);
          });
    } catch(e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao excluir personagem: $e'),
      );
    }
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getString(_storageKey);

      if (result == null || result.isEmpty) {
        return Error(EmptyResultFailure());
      }

      final decoded = jsonDecode(result) as List<dynamic>;

      final characters = decoded
          .map((e) => CharacterMapper.fromMap(e as Map<String, dynamic>))
          .toList();

      return Success(characters);
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter personagens: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) {
    // TODO: implement getCharacterById
    throw UnimplementedError();
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) async {
    try{
      final result = await getAllCharacters();

      return await result.fold(
        onSuccess: (characters) async {
          final indexEditedCharacter = characters.indexWhere((c) => c.id == character.id);

          if(indexEditedCharacter == -1){
            return Error(ApiLocalFailure('Shared Preferences: Personagem não encontrado, id: ${character.id}') );
          }

          final updatedList = characters.map((c) => c.id == character.id ? character : c).toList();
          await _saveCharacters(updatedList);

          return Success(character);
        }, 
        
        onFailure: (failure) async {
          if(failure  is EmptyResultFailure){
            return Error(ApiLocalFailure('Shared Preferences: Nenhum personagem para editar'));
          }
          return Error(failure);
        },
      );
    } catch(e) {
      return Error(
        ApiLocalFailure('Shared Preferences: Erro ao atualizar personagem: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final updatedCharacters = [...characters, character];
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (failure) async {
          if (failure is EmptyResultFailure) {
            await _saveCharacters([character]);
            return Success(character);
          }

          return Error(ApiLocalFailure());
        },
      );
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao salvar personagem: $e'),
      );
    }
  }

  /// Salva os personagens no storage
  Future<void> _saveCharacters(List<Character> characters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        characters.map((c) => CharacterMapper.toMap(c)).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      throw ApiLocalFailure('Erro ao salvar personagens: $e');
    }
  }
}
