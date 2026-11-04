// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TaskEntriesTable extends TaskEntries
    with TableInfo<$TaskEntriesTable, TaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    isCompleted,
    priority,
    dueDate,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $TaskEntriesTable createAlias(String alias) {
    return $TaskEntriesTable(attachedDatabase, alias);
  }
}

class TaskEntry extends DataClass implements Insertable<TaskEntry> {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  const TaskEntry({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  TaskEntriesCompanion toCompanion(bool nullToAbsent) {
    return TaskEntriesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isCompleted: Value(isCompleted),
      priority: Value(priority),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory TaskEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      priority: serializer.fromJson<String>(json['priority']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'priority': serializer.toJson<String>(priority),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  TaskEntry copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    bool? isCompleted,
    String? priority,
    Value<DateTime?> dueDate = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => TaskEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    priority: priority ?? this.priority,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  TaskEntry copyWithCompanion(TaskEntriesCompanion data) {
    return TaskEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      priority: data.priority.present ? data.priority.value : this.priority,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    isCompleted,
    priority,
    dueDate,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.isCompleted == this.isCompleted &&
          other.priority == this.priority &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class TaskEntriesCompanion extends UpdateCompanion<TaskEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> isCompleted;
  final Value<String> priority;
  final Value<DateTime?> dueDate;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const TaskEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskEntriesCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<TaskEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isCompleted,
    Expression<String>? priority,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<bool>? isCompleted,
    Value<String>? priority,
    Value<DateTime?>? dueDate,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return TaskEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionEntriesTable extends FocusSessionEntries
    with TableInfo<$FocusSessionEntriesTable, FocusSessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    durationSeconds,
    completedAt,
    taskId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_session_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
    );
  }

  @override
  $FocusSessionEntriesTable createAlias(String alias) {
    return $FocusSessionEntriesTable(attachedDatabase, alias);
  }
}

class FocusSessionEntry extends DataClass
    implements Insertable<FocusSessionEntry> {
  final String id;
  final String mode;
  final int durationSeconds;
  final DateTime completedAt;
  final String? taskId;
  const FocusSessionEntry({
    required this.id,
    required this.mode,
    required this.durationSeconds,
    required this.completedAt,
    this.taskId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mode'] = Variable<String>(mode);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    return map;
  }

  FocusSessionEntriesCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionEntriesCompanion(
      id: Value(id),
      mode: Value(mode),
      durationSeconds: Value(durationSeconds),
      completedAt: Value(completedAt),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
    );
  }

  factory FocusSessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionEntry(
      id: serializer.fromJson<String>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      taskId: serializer.fromJson<String?>(json['taskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mode': serializer.toJson<String>(mode),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'taskId': serializer.toJson<String?>(taskId),
    };
  }

  FocusSessionEntry copyWith({
    String? id,
    String? mode,
    int? durationSeconds,
    DateTime? completedAt,
    Value<String?> taskId = const Value.absent(),
  }) => FocusSessionEntry(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    completedAt: completedAt ?? this.completedAt,
    taskId: taskId.present ? taskId.value : this.taskId,
  );
  FocusSessionEntry copyWithCompanion(FocusSessionEntriesCompanion data) {
    return FocusSessionEntry(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionEntry(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mode, durationSeconds, completedAt, taskId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionEntry &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.durationSeconds == this.durationSeconds &&
          other.completedAt == this.completedAt &&
          other.taskId == this.taskId);
}

class FocusSessionEntriesCompanion extends UpdateCompanion<FocusSessionEntry> {
  final Value<String> id;
  final Value<String> mode;
  final Value<int> durationSeconds;
  final Value<DateTime> completedAt;
  final Value<String?> taskId;
  final Value<int> rowid;
  const FocusSessionEntriesCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusSessionEntriesCompanion.insert({
    required String id,
    required String mode,
    required int durationSeconds,
    required DateTime completedAt,
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mode = Value(mode),
       durationSeconds = Value(durationSeconds),
       completedAt = Value(completedAt);
  static Insertable<FocusSessionEntry> custom({
    Expression<String>? id,
    Expression<String>? mode,
    Expression<int>? durationSeconds,
    Expression<DateTime>? completedAt,
    Expression<String>? taskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completedAt != null) 'completed_at': completedAt,
      if (taskId != null) 'task_id': taskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusSessionEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? mode,
    Value<int>? durationSeconds,
    Value<DateTime>? completedAt,
    Value<String?>? taskId,
    Value<int>? rowid,
  }) {
    return FocusSessionEntriesCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedAt: completedAt ?? this.completedAt,
      taskId: taskId ?? this.taskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt, ')
          ..write('taskId: $taskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsEntriesTable extends UserSettingsEntries
    with TableInfo<$UserSettingsEntriesTable, UserSettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workDurationMinutesMeta =
      const VerificationMeta('workDurationMinutes');
  @override
  late final GeneratedColumn<int> workDurationMinutes = GeneratedColumn<int>(
    'work_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _shortBreakDurationMinutesMeta =
      const VerificationMeta('shortBreakDurationMinutes');
  @override
  late final GeneratedColumn<int> shortBreakDurationMinutes =
      GeneratedColumn<int>(
        'short_break_duration_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(5),
      );
  static const VerificationMeta _longBreakDurationMinutesMeta =
      const VerificationMeta('longBreakDurationMinutes');
  @override
  late final GeneratedColumn<int> longBreakDurationMinutes =
      GeneratedColumn<int>(
        'long_break_duration_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(15),
      );
  static const VerificationMeta _dailyGoalMinutesMeta = const VerificationMeta(
    'dailyGoalMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyGoalMinutes = GeneratedColumn<int>(
    'daily_goal_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workDurationMinutes,
    shortBreakDurationMinutes,
    longBreakDurationMinutes,
    dailyGoalMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('work_duration_minutes')) {
      context.handle(
        _workDurationMinutesMeta,
        workDurationMinutes.isAcceptableOrUnknown(
          data['work_duration_minutes']!,
          _workDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('short_break_duration_minutes')) {
      context.handle(
        _shortBreakDurationMinutesMeta,
        shortBreakDurationMinutes.isAcceptableOrUnknown(
          data['short_break_duration_minutes']!,
          _shortBreakDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('long_break_duration_minutes')) {
      context.handle(
        _longBreakDurationMinutesMeta,
        longBreakDurationMinutes.isAcceptableOrUnknown(
          data['long_break_duration_minutes']!,
          _longBreakDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('daily_goal_minutes')) {
      context.handle(
        _dailyGoalMinutesMeta,
        dailyGoalMinutes.isAcceptableOrUnknown(
          data['daily_goal_minutes']!,
          _dailyGoalMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_duration_minutes'],
      )!,
      shortBreakDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}short_break_duration_minutes'],
      )!,
      longBreakDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}long_break_duration_minutes'],
      )!,
      dailyGoalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_minutes'],
      )!,
    );
  }

  @override
  $UserSettingsEntriesTable createAlias(String alias) {
    return $UserSettingsEntriesTable(attachedDatabase, alias);
  }
}

class UserSettingsEntry extends DataClass
    implements Insertable<UserSettingsEntry> {
  final String id;
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int dailyGoalMinutes;
  const UserSettingsEntry({
    required this.id,
    required this.workDurationMinutes,
    required this.shortBreakDurationMinutes,
    required this.longBreakDurationMinutes,
    required this.dailyGoalMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['work_duration_minutes'] = Variable<int>(workDurationMinutes);
    map['short_break_duration_minutes'] = Variable<int>(
      shortBreakDurationMinutes,
    );
    map['long_break_duration_minutes'] = Variable<int>(
      longBreakDurationMinutes,
    );
    map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes);
    return map;
  }

  UserSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsEntriesCompanion(
      id: Value(id),
      workDurationMinutes: Value(workDurationMinutes),
      shortBreakDurationMinutes: Value(shortBreakDurationMinutes),
      longBreakDurationMinutes: Value(longBreakDurationMinutes),
      dailyGoalMinutes: Value(dailyGoalMinutes),
    );
  }

  factory UserSettingsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsEntry(
      id: serializer.fromJson<String>(json['id']),
      workDurationMinutes: serializer.fromJson<int>(
        json['workDurationMinutes'],
      ),
      shortBreakDurationMinutes: serializer.fromJson<int>(
        json['shortBreakDurationMinutes'],
      ),
      longBreakDurationMinutes: serializer.fromJson<int>(
        json['longBreakDurationMinutes'],
      ),
      dailyGoalMinutes: serializer.fromJson<int>(json['dailyGoalMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workDurationMinutes': serializer.toJson<int>(workDurationMinutes),
      'shortBreakDurationMinutes': serializer.toJson<int>(
        shortBreakDurationMinutes,
      ),
      'longBreakDurationMinutes': serializer.toJson<int>(
        longBreakDurationMinutes,
      ),
      'dailyGoalMinutes': serializer.toJson<int>(dailyGoalMinutes),
    };
  }

  UserSettingsEntry copyWith({
    String? id,
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? dailyGoalMinutes,
  }) => UserSettingsEntry(
    id: id ?? this.id,
    workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
    shortBreakDurationMinutes:
        shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
    longBreakDurationMinutes:
        longBreakDurationMinutes ?? this.longBreakDurationMinutes,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
  );
  UserSettingsEntry copyWithCompanion(UserSettingsEntriesCompanion data) {
    return UserSettingsEntry(
      id: data.id.present ? data.id.value : this.id,
      workDurationMinutes: data.workDurationMinutes.present
          ? data.workDurationMinutes.value
          : this.workDurationMinutes,
      shortBreakDurationMinutes: data.shortBreakDurationMinutes.present
          ? data.shortBreakDurationMinutes.value
          : this.shortBreakDurationMinutes,
      longBreakDurationMinutes: data.longBreakDurationMinutes.present
          ? data.longBreakDurationMinutes.value
          : this.longBreakDurationMinutes,
      dailyGoalMinutes: data.dailyGoalMinutes.present
          ? data.dailyGoalMinutes.value
          : this.dailyGoalMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsEntry(')
          ..write('id: $id, ')
          ..write('workDurationMinutes: $workDurationMinutes, ')
          ..write('shortBreakDurationMinutes: $shortBreakDurationMinutes, ')
          ..write('longBreakDurationMinutes: $longBreakDurationMinutes, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workDurationMinutes,
    shortBreakDurationMinutes,
    longBreakDurationMinutes,
    dailyGoalMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsEntry &&
          other.id == this.id &&
          other.workDurationMinutes == this.workDurationMinutes &&
          other.shortBreakDurationMinutes == this.shortBreakDurationMinutes &&
          other.longBreakDurationMinutes == this.longBreakDurationMinutes &&
          other.dailyGoalMinutes == this.dailyGoalMinutes);
}

class UserSettingsEntriesCompanion extends UpdateCompanion<UserSettingsEntry> {
  final Value<String> id;
  final Value<int> workDurationMinutes;
  final Value<int> shortBreakDurationMinutes;
  final Value<int> longBreakDurationMinutes;
  final Value<int> dailyGoalMinutes;
  final Value<int> rowid;
  const UserSettingsEntriesCompanion({
    this.id = const Value.absent(),
    this.workDurationMinutes = const Value.absent(),
    this.shortBreakDurationMinutes = const Value.absent(),
    this.longBreakDurationMinutes = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsEntriesCompanion.insert({
    required String id,
    this.workDurationMinutes = const Value.absent(),
    this.shortBreakDurationMinutes = const Value.absent(),
    this.longBreakDurationMinutes = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserSettingsEntry> custom({
    Expression<String>? id,
    Expression<int>? workDurationMinutes,
    Expression<int>? shortBreakDurationMinutes,
    Expression<int>? longBreakDurationMinutes,
    Expression<int>? dailyGoalMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workDurationMinutes != null)
        'work_duration_minutes': workDurationMinutes,
      if (shortBreakDurationMinutes != null)
        'short_break_duration_minutes': shortBreakDurationMinutes,
      if (longBreakDurationMinutes != null)
        'long_break_duration_minutes': longBreakDurationMinutes,
      if (dailyGoalMinutes != null) 'daily_goal_minutes': dailyGoalMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? workDurationMinutes,
    Value<int>? shortBreakDurationMinutes,
    Value<int>? longBreakDurationMinutes,
    Value<int>? dailyGoalMinutes,
    Value<int>? rowid,
  }) {
    return UserSettingsEntriesCompanion(
      id: id ?? this.id,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workDurationMinutes.present) {
      map['work_duration_minutes'] = Variable<int>(workDurationMinutes.value);
    }
    if (shortBreakDurationMinutes.present) {
      map['short_break_duration_minutes'] = Variable<int>(
        shortBreakDurationMinutes.value,
      );
    }
    if (longBreakDurationMinutes.present) {
      map['long_break_duration_minutes'] = Variable<int>(
        longBreakDurationMinutes.value,
      );
    }
    if (dailyGoalMinutes.present) {
      map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsEntriesCompanion(')
          ..write('id: $id, ')
          ..write('workDurationMinutes: $workDurationMinutes, ')
          ..write('shortBreakDurationMinutes: $shortBreakDurationMinutes, ')
          ..write('longBreakDurationMinutes: $longBreakDurationMinutes, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TaskEntriesTable taskEntries = $TaskEntriesTable(this);
  late final $FocusSessionEntriesTable focusSessionEntries =
      $FocusSessionEntriesTable(this);
  late final $UserSettingsEntriesTable userSettingsEntries =
      $UserSettingsEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    taskEntries,
    focusSessionEntries,
    userSettingsEntries,
  ];
}

typedef $$TaskEntriesTableCreateCompanionBuilder =
    TaskEntriesCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<bool> isCompleted,
      Value<String> priority,
      Value<DateTime?> dueDate,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$TaskEntriesTableUpdateCompanionBuilder =
    TaskEntriesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<bool> isCompleted,
      Value<String> priority,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$TaskEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskEntriesTable> {
  $$TaskEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskEntriesTable> {
  $$TaskEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskEntriesTable> {
  $$TaskEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$TaskEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskEntriesTable,
          TaskEntry,
          $$TaskEntriesTableFilterComposer,
          $$TaskEntriesTableOrderingComposer,
          $$TaskEntriesTableAnnotationComposer,
          $$TaskEntriesTableCreateCompanionBuilder,
          $$TaskEntriesTableUpdateCompanionBuilder,
          (
            TaskEntry,
            BaseReferences<_$AppDatabase, $TaskEntriesTable, TaskEntry>,
          ),
          TaskEntry,
          PrefetchHooks Function()
        > {
  $$TaskEntriesTableTableManager(_$AppDatabase db, $TaskEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskEntriesCompanion(
                id: id,
                title: title,
                description: description,
                isCompleted: isCompleted,
                priority: priority,
                dueDate: dueDate,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskEntriesCompanion.insert(
                id: id,
                title: title,
                description: description,
                isCompleted: isCompleted,
                priority: priority,
                dueDate: dueDate,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskEntriesTable, TaskEntry>(table),
                  BaseReferences<_$AppDatabase, $TaskEntriesTable, TaskEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskEntriesTable,
      TaskEntry,
      $$TaskEntriesTableFilterComposer,
      $$TaskEntriesTableOrderingComposer,
      $$TaskEntriesTableAnnotationComposer,
      $$TaskEntriesTableCreateCompanionBuilder,
      $$TaskEntriesTableUpdateCompanionBuilder,
      (TaskEntry, BaseReferences<_$AppDatabase, $TaskEntriesTable, TaskEntry>),
      TaskEntry,
      PrefetchHooks Function()
    >;
typedef $$FocusSessionEntriesTableCreateCompanionBuilder =
    FocusSessionEntriesCompanion Function({
      required String id,
      required String mode,
      required int durationSeconds,
      required DateTime completedAt,
      Value<String?> taskId,
      Value<int> rowid,
    });
typedef $$FocusSessionEntriesTableUpdateCompanionBuilder =
    FocusSessionEntriesCompanion Function({
      Value<String> id,
      Value<String> mode,
      Value<int> durationSeconds,
      Value<DateTime> completedAt,
      Value<String?> taskId,
      Value<int> rowid,
    });

class $$FocusSessionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionEntriesTable> {
  $$FocusSessionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FocusSessionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionEntriesTable> {
  $$FocusSessionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusSessionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionEntriesTable> {
  $$FocusSessionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);
}

class $$FocusSessionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionEntriesTable,
          FocusSessionEntry,
          $$FocusSessionEntriesTableFilterComposer,
          $$FocusSessionEntriesTableOrderingComposer,
          $$FocusSessionEntriesTableAnnotationComposer,
          $$FocusSessionEntriesTableCreateCompanionBuilder,
          $$FocusSessionEntriesTableUpdateCompanionBuilder,
          (
            FocusSessionEntry,
            BaseReferences<
              _$AppDatabase,
              $FocusSessionEntriesTable,
              FocusSessionEntry
            >,
          ),
          FocusSessionEntry,
          PrefetchHooks Function()
        > {
  $$FocusSessionEntriesTableTableManager(
    _$AppDatabase db,
    $FocusSessionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FocusSessionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionEntriesCompanion(
                id: id,
                mode: mode,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
                taskId: taskId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mode,
                required int durationSeconds,
                required DateTime completedAt,
                Value<String?> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionEntriesCompanion.insert(
                id: id,
                mode: mode,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
                taskId: taskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FocusSessionEntriesTable, FocusSessionEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $FocusSessionEntriesTable,
                    FocusSessionEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FocusSessionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionEntriesTable,
      FocusSessionEntry,
      $$FocusSessionEntriesTableFilterComposer,
      $$FocusSessionEntriesTableOrderingComposer,
      $$FocusSessionEntriesTableAnnotationComposer,
      $$FocusSessionEntriesTableCreateCompanionBuilder,
      $$FocusSessionEntriesTableUpdateCompanionBuilder,
      (
        FocusSessionEntry,
        BaseReferences<
          _$AppDatabase,
          $FocusSessionEntriesTable,
          FocusSessionEntry
        >,
      ),
      FocusSessionEntry,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsEntriesTableCreateCompanionBuilder =
    UserSettingsEntriesCompanion Function({
      required String id,
      Value<int> workDurationMinutes,
      Value<int> shortBreakDurationMinutes,
      Value<int> longBreakDurationMinutes,
      Value<int> dailyGoalMinutes,
      Value<int> rowid,
    });
typedef $$UserSettingsEntriesTableUpdateCompanionBuilder =
    UserSettingsEntriesCompanion Function({
      Value<String> id,
      Value<int> workDurationMinutes,
      Value<int> shortBreakDurationMinutes,
      Value<int> longBreakDurationMinutes,
      Value<int> dailyGoalMinutes,
      Value<int> rowid,
    });

class $$UserSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsEntriesTable> {
  $$UserSettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workDurationMinutes => $composableBuilder(
    column: $table.workDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortBreakDurationMinutes => $composableBuilder(
    column: $table.shortBreakDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longBreakDurationMinutes => $composableBuilder(
    column: $table.longBreakDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsEntriesTable> {
  $$UserSettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workDurationMinutes => $composableBuilder(
    column: $table.workDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortBreakDurationMinutes => $composableBuilder(
    column: $table.shortBreakDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longBreakDurationMinutes => $composableBuilder(
    column: $table.longBreakDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsEntriesTable> {
  $$UserSettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workDurationMinutes => $composableBuilder(
    column: $table.workDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shortBreakDurationMinutes => $composableBuilder(
    column: $table.shortBreakDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longBreakDurationMinutes => $composableBuilder(
    column: $table.longBreakDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => column,
  );
}

class $$UserSettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsEntriesTable,
          UserSettingsEntry,
          $$UserSettingsEntriesTableFilterComposer,
          $$UserSettingsEntriesTableOrderingComposer,
          $$UserSettingsEntriesTableAnnotationComposer,
          $$UserSettingsEntriesTableCreateCompanionBuilder,
          $$UserSettingsEntriesTableUpdateCompanionBuilder,
          (
            UserSettingsEntry,
            BaseReferences<
              _$AppDatabase,
              $UserSettingsEntriesTable,
              UserSettingsEntry
            >,
          ),
          UserSettingsEntry,
          PrefetchHooks Function()
        > {
  $$UserSettingsEntriesTableTableManager(
    _$AppDatabase db,
    $UserSettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserSettingsEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> workDurationMinutes = const Value.absent(),
                Value<int> shortBreakDurationMinutes = const Value.absent(),
                Value<int> longBreakDurationMinutes = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsEntriesCompanion(
                id: id,
                workDurationMinutes: workDurationMinutes,
                shortBreakDurationMinutes: shortBreakDurationMinutes,
                longBreakDurationMinutes: longBreakDurationMinutes,
                dailyGoalMinutes: dailyGoalMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> workDurationMinutes = const Value.absent(),
                Value<int> shortBreakDurationMinutes = const Value.absent(),
                Value<int> longBreakDurationMinutes = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsEntriesCompanion.insert(
                id: id,
                workDurationMinutes: workDurationMinutes,
                shortBreakDurationMinutes: shortBreakDurationMinutes,
                longBreakDurationMinutes: longBreakDurationMinutes,
                dailyGoalMinutes: dailyGoalMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserSettingsEntriesTable, UserSettingsEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $UserSettingsEntriesTable,
                    UserSettingsEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsEntriesTable,
      UserSettingsEntry,
      $$UserSettingsEntriesTableFilterComposer,
      $$UserSettingsEntriesTableOrderingComposer,
      $$UserSettingsEntriesTableAnnotationComposer,
      $$UserSettingsEntriesTableCreateCompanionBuilder,
      $$UserSettingsEntriesTableUpdateCompanionBuilder,
      (
        UserSettingsEntry,
        BaseReferences<
          _$AppDatabase,
          $UserSettingsEntriesTable,
          UserSettingsEntry
        >,
      ),
      UserSettingsEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TaskEntriesTableTableManager get taskEntries =>
      $$TaskEntriesTableTableManager(_db, _db.taskEntries);
  $$FocusSessionEntriesTableTableManager get focusSessionEntries =>
      $$FocusSessionEntriesTableTableManager(_db, _db.focusSessionEntries);
  $$UserSettingsEntriesTableTableManager get userSettingsEntries =>
      $$UserSettingsEntriesTableTableManager(_db, _db.userSettingsEntries);
}
