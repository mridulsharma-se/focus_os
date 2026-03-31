// lib/models/memory.dart
import 'package:hive/hive.dart';

class Memory {
  final String id;
  final String content;
  final String source;
  final String sender;
  final DateTime timestamp;
  final List<String> tags;
  final bool isImportant;

  Memory({
    required this.id,
    required this.content,
    required this.source,
    required this.sender,
    required this.timestamp,
    required this.tags,
    required this.isImportant,
  });
}

class MemoryAdapter extends TypeAdapter<Memory> {
  @override
  final int typeId = 0;

  @override
  Memory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Memory(
      id: fields[0] as String,
      content: fields[1] as String,
      source: fields[2] as String,
      sender: fields[3] as String,
      timestamp: fields[4] as DateTime,
      tags: (fields[5] as List?)?.cast<String>() ?? <String>[],
      isImportant: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Memory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.source)
      ..writeByte(3)
      ..write(obj.sender)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.isImportant);
  }
}
