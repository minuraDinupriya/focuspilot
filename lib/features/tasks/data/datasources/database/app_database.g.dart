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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualMinutesMeta = const VerificationMeta(
    'actualMinutes',
  );
  @override
  late final GeneratedColumn<int> actualMinutes = GeneratedColumn<int>(
    'actual_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    category,
    tags,
    estimatedMinutes,
    actualMinutes,
    recurrenceRule,
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('actual_minutes')) {
      context.handle(
        _actualMinutesMeta,
        actualMinutes.isAcceptableOrUnknown(
          data['actual_minutes']!,
          _actualMinutesMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
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
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
      actualMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_minutes'],
      )!,
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
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
  final String? category;
  final String tags;
  final int? estimatedMinutes;
  final int actualMinutes;
  final String? recurrenceRule;
  const TaskEntry({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
    this.category,
    required this.tags,
    this.estimatedMinutes,
    required this.actualMinutes,
    this.recurrenceRule,
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
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    map['actual_minutes'] = Variable<int>(actualMinutes);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
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
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      tags: Value(tags),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      actualMinutes: Value(actualMinutes),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
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
      category: serializer.fromJson<String?>(json['category']),
      tags: serializer.fromJson<String>(json['tags']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      actualMinutes: serializer.fromJson<int>(json['actualMinutes']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
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
      'category': serializer.toJson<String?>(category),
      'tags': serializer.toJson<String>(tags),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'actualMinutes': serializer.toJson<int>(actualMinutes),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
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
    Value<String?> category = const Value.absent(),
    String? tags,
    Value<int?> estimatedMinutes = const Value.absent(),
    int? actualMinutes,
    Value<String?> recurrenceRule = const Value.absent(),
  }) => TaskEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    priority: priority ?? this.priority,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    category: category.present ? category.value : this.category,
    tags: tags ?? this.tags,
    estimatedMinutes: estimatedMinutes.present
        ? estimatedMinutes.value
        : this.estimatedMinutes,
    actualMinutes: actualMinutes ?? this.actualMinutes,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
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
      category: data.category.present ? data.category.value : this.category,
      tags: data.tags.present ? data.tags.value : this.tags,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      actualMinutes: data.actualMinutes.present
          ? data.actualMinutes.value
          : this.actualMinutes,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
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
          ..write('completedAt: $completedAt, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('recurrenceRule: $recurrenceRule')
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
    category,
    tags,
    estimatedMinutes,
    actualMinutes,
    recurrenceRule,
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
          other.completedAt == this.completedAt &&
          other.category == this.category &&
          other.tags == this.tags &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.actualMinutes == this.actualMinutes &&
          other.recurrenceRule == this.recurrenceRule);
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
  final Value<String?> category;
  final Value<String> tags;
  final Value<int?> estimatedMinutes;
  final Value<int> actualMinutes;
  final Value<String?> recurrenceRule;
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
    this.category = const Value.absent(),
    this.tags = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
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
    this.category = const Value.absent(),
    this.tags = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
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
    Expression<String>? category,
    Expression<String>? tags,
    Expression<int>? estimatedMinutes,
    Expression<int>? actualMinutes,
    Expression<String>? recurrenceRule,
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
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (actualMinutes != null) 'actual_minutes': actualMinutes,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
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
    Value<String?>? category,
    Value<String>? tags,
    Value<int?>? estimatedMinutes,
    Value<int>? actualMinutes,
    Value<String?>? recurrenceRule,
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
      category: category ?? this.category,
      tags: tags ?? this.tags,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (actualMinutes.present) {
      map['actual_minutes'] = Variable<int>(actualMinutes.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
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
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubtaskEntriesTable extends SubtaskEntries
    with TableInfo<$SubtaskEntriesTable, SubtaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtaskEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task_entries (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    title,
    isCompleted,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtask_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubtaskEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubtaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubtaskEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $SubtaskEntriesTable createAlias(String alias) {
    return $SubtaskEntriesTable(attachedDatabase, alias);
  }
}

class SubtaskEntry extends DataClass implements Insertable<SubtaskEntry> {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int orderIndex;
  const SubtaskEntry({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  SubtaskEntriesCompanion toCompanion(bool nullToAbsent) {
    return SubtaskEntriesCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      isCompleted: Value(isCompleted),
      orderIndex: Value(orderIndex),
    );
  }

  factory SubtaskEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubtaskEntry(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  SubtaskEntry copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    int? orderIndex,
  }) => SubtaskEntry(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  SubtaskEntry copyWithCompanion(SubtaskEntriesCompanion data) {
    return SubtaskEntry(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubtaskEntry(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, title, isCompleted, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubtaskEntry &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.orderIndex == this.orderIndex);
}

class SubtaskEntriesCompanion extends UpdateCompanion<SubtaskEntry> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const SubtaskEntriesCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubtaskEntriesCompanion.insert({
    required String id,
    required String taskId,
    required String title,
    this.isCompleted = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       title = Value(title);
  static Insertable<SubtaskEntry> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubtaskEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? title,
    Value<bool>? isCompleted,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return SubtaskEntriesCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtaskEntriesCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('orderIndex: $orderIndex, ')
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
  static const VerificationMeta _distractionCountMeta = const VerificationMeta(
    'distractionCount',
  );
  @override
  late final GeneratedColumn<int> distractionCount = GeneratedColumn<int>(
    'distraction_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    durationSeconds,
    completedAt,
    taskId,
    distractionCount,
    status,
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
    if (data.containsKey('distraction_count')) {
      context.handle(
        _distractionCountMeta,
        distractionCount.isAcceptableOrUnknown(
          data['distraction_count']!,
          _distractionCountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
      distractionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distraction_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
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
  final int distractionCount;
  final String status;
  const FocusSessionEntry({
    required this.id,
    required this.mode,
    required this.durationSeconds,
    required this.completedAt,
    this.taskId,
    required this.distractionCount,
    required this.status,
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
    map['distraction_count'] = Variable<int>(distractionCount);
    map['status'] = Variable<String>(status);
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
      distractionCount: Value(distractionCount),
      status: Value(status),
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
      distractionCount: serializer.fromJson<int>(json['distractionCount']),
      status: serializer.fromJson<String>(json['status']),
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
      'distractionCount': serializer.toJson<int>(distractionCount),
      'status': serializer.toJson<String>(status),
    };
  }

  FocusSessionEntry copyWith({
    String? id,
    String? mode,
    int? durationSeconds,
    DateTime? completedAt,
    Value<String?> taskId = const Value.absent(),
    int? distractionCount,
    String? status,
  }) => FocusSessionEntry(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    completedAt: completedAt ?? this.completedAt,
    taskId: taskId.present ? taskId.value : this.taskId,
    distractionCount: distractionCount ?? this.distractionCount,
    status: status ?? this.status,
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
      distractionCount: data.distractionCount.present
          ? data.distractionCount.value
          : this.distractionCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionEntry(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt, ')
          ..write('taskId: $taskId, ')
          ..write('distractionCount: $distractionCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    durationSeconds,
    completedAt,
    taskId,
    distractionCount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionEntry &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.durationSeconds == this.durationSeconds &&
          other.completedAt == this.completedAt &&
          other.taskId == this.taskId &&
          other.distractionCount == this.distractionCount &&
          other.status == this.status);
}

class FocusSessionEntriesCompanion extends UpdateCompanion<FocusSessionEntry> {
  final Value<String> id;
  final Value<String> mode;
  final Value<int> durationSeconds;
  final Value<DateTime> completedAt;
  final Value<String?> taskId;
  final Value<int> distractionCount;
  final Value<String> status;
  final Value<int> rowid;
  const FocusSessionEntriesCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.taskId = const Value.absent(),
    this.distractionCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusSessionEntriesCompanion.insert({
    required String id,
    required String mode,
    required int durationSeconds,
    required DateTime completedAt,
    this.taskId = const Value.absent(),
    this.distractionCount = const Value.absent(),
    this.status = const Value.absent(),
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
    Expression<int>? distractionCount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completedAt != null) 'completed_at': completedAt,
      if (taskId != null) 'task_id': taskId,
      if (distractionCount != null) 'distraction_count': distractionCount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusSessionEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? mode,
    Value<int>? durationSeconds,
    Value<DateTime>? completedAt,
    Value<String?>? taskId,
    Value<int>? distractionCount,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return FocusSessionEntriesCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedAt: completedAt ?? this.completedAt,
      taskId: taskId ?? this.taskId,
      distractionCount: distractionCount ?? this.distractionCount,
      status: status ?? this.status,
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
    if (distractionCount.present) {
      map['distraction_count'] = Variable<int>(distractionCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
          ..write('distractionCount: $distractionCount, ')
          ..write('status: $status, ')
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
  static const VerificationMeta _weeklyGoalMinutesMeta = const VerificationMeta(
    'weeklyGoalMinutes',
  );
  @override
  late final GeneratedColumn<int> weeklyGoalMinutes = GeneratedColumn<int>(
    'weekly_goal_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(600),
  );
  static const VerificationMeta _activePresetIdMeta = const VerificationMeta(
    'activePresetId',
  );
  @override
  late final GeneratedColumn<String> activePresetId = GeneratedColumn<String>(
    'active_preset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('preset-classic'),
  );
  static const VerificationMeta _autoStartNextSessionMeta =
      const VerificationMeta('autoStartNextSession');
  @override
  late final GeneratedColumn<bool> autoStartNextSession = GeneratedColumn<bool>(
    'auto_start_next_session',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_start_next_session" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hapticEnabledMeta = const VerificationMeta(
    'hapticEnabled',
  );
  @override
  late final GeneratedColumn<bool> hapticEnabled = GeneratedColumn<bool>(
    'haptic_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptic_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workDurationMinutes,
    shortBreakDurationMinutes,
    longBreakDurationMinutes,
    dailyGoalMinutes,
    weeklyGoalMinutes,
    activePresetId,
    autoStartNextSession,
    soundEnabled,
    hapticEnabled,
    themeMode,
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
    if (data.containsKey('weekly_goal_minutes')) {
      context.handle(
        _weeklyGoalMinutesMeta,
        weeklyGoalMinutes.isAcceptableOrUnknown(
          data['weekly_goal_minutes']!,
          _weeklyGoalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('active_preset_id')) {
      context.handle(
        _activePresetIdMeta,
        activePresetId.isAcceptableOrUnknown(
          data['active_preset_id']!,
          _activePresetIdMeta,
        ),
      );
    }
    if (data.containsKey('auto_start_next_session')) {
      context.handle(
        _autoStartNextSessionMeta,
        autoStartNextSession.isAcceptableOrUnknown(
          data['auto_start_next_session']!,
          _autoStartNextSessionMeta,
        ),
      );
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    }
    if (data.containsKey('haptic_enabled')) {
      context.handle(
        _hapticEnabledMeta,
        hapticEnabled.isAcceptableOrUnknown(
          data['haptic_enabled']!,
          _hapticEnabledMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
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
      weeklyGoalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_goal_minutes'],
      )!,
      activePresetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_preset_id'],
      ),
      autoStartNextSession: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_start_next_session'],
      )!,
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
      hapticEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptic_enabled'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
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
  final int weeklyGoalMinutes;
  final String? activePresetId;
  final bool autoStartNextSession;
  final bool soundEnabled;
  final bool hapticEnabled;
  final String themeMode;
  const UserSettingsEntry({
    required this.id,
    required this.workDurationMinutes,
    required this.shortBreakDurationMinutes,
    required this.longBreakDurationMinutes,
    required this.dailyGoalMinutes,
    required this.weeklyGoalMinutes,
    this.activePresetId,
    required this.autoStartNextSession,
    required this.soundEnabled,
    required this.hapticEnabled,
    required this.themeMode,
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
    map['weekly_goal_minutes'] = Variable<int>(weeklyGoalMinutes);
    if (!nullToAbsent || activePresetId != null) {
      map['active_preset_id'] = Variable<String>(activePresetId);
    }
    map['auto_start_next_session'] = Variable<bool>(autoStartNextSession);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['haptic_enabled'] = Variable<bool>(hapticEnabled);
    map['theme_mode'] = Variable<String>(themeMode);
    return map;
  }

  UserSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsEntriesCompanion(
      id: Value(id),
      workDurationMinutes: Value(workDurationMinutes),
      shortBreakDurationMinutes: Value(shortBreakDurationMinutes),
      longBreakDurationMinutes: Value(longBreakDurationMinutes),
      dailyGoalMinutes: Value(dailyGoalMinutes),
      weeklyGoalMinutes: Value(weeklyGoalMinutes),
      activePresetId: activePresetId == null && nullToAbsent
          ? const Value.absent()
          : Value(activePresetId),
      autoStartNextSession: Value(autoStartNextSession),
      soundEnabled: Value(soundEnabled),
      hapticEnabled: Value(hapticEnabled),
      themeMode: Value(themeMode),
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
      weeklyGoalMinutes: serializer.fromJson<int>(json['weeklyGoalMinutes']),
      activePresetId: serializer.fromJson<String?>(json['activePresetId']),
      autoStartNextSession: serializer.fromJson<bool>(
        json['autoStartNextSession'],
      ),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      hapticEnabled: serializer.fromJson<bool>(json['hapticEnabled']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
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
      'weeklyGoalMinutes': serializer.toJson<int>(weeklyGoalMinutes),
      'activePresetId': serializer.toJson<String?>(activePresetId),
      'autoStartNextSession': serializer.toJson<bool>(autoStartNextSession),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'hapticEnabled': serializer.toJson<bool>(hapticEnabled),
      'themeMode': serializer.toJson<String>(themeMode),
    };
  }

  UserSettingsEntry copyWith({
    String? id,
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? dailyGoalMinutes,
    int? weeklyGoalMinutes,
    Value<String?> activePresetId = const Value.absent(),
    bool? autoStartNextSession,
    bool? soundEnabled,
    bool? hapticEnabled,
    String? themeMode,
  }) => UserSettingsEntry(
    id: id ?? this.id,
    workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
    shortBreakDurationMinutes:
        shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
    longBreakDurationMinutes:
        longBreakDurationMinutes ?? this.longBreakDurationMinutes,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
    activePresetId: activePresetId.present
        ? activePresetId.value
        : this.activePresetId,
    autoStartNextSession: autoStartNextSession ?? this.autoStartNextSession,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    themeMode: themeMode ?? this.themeMode,
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
      weeklyGoalMinutes: data.weeklyGoalMinutes.present
          ? data.weeklyGoalMinutes.value
          : this.weeklyGoalMinutes,
      activePresetId: data.activePresetId.present
          ? data.activePresetId.value
          : this.activePresetId,
      autoStartNextSession: data.autoStartNextSession.present
          ? data.autoStartNextSession.value
          : this.autoStartNextSession,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      hapticEnabled: data.hapticEnabled.present
          ? data.hapticEnabled.value
          : this.hapticEnabled,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsEntry(')
          ..write('id: $id, ')
          ..write('workDurationMinutes: $workDurationMinutes, ')
          ..write('shortBreakDurationMinutes: $shortBreakDurationMinutes, ')
          ..write('longBreakDurationMinutes: $longBreakDurationMinutes, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('weeklyGoalMinutes: $weeklyGoalMinutes, ')
          ..write('activePresetId: $activePresetId, ')
          ..write('autoStartNextSession: $autoStartNextSession, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('hapticEnabled: $hapticEnabled, ')
          ..write('themeMode: $themeMode')
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
    weeklyGoalMinutes,
    activePresetId,
    autoStartNextSession,
    soundEnabled,
    hapticEnabled,
    themeMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsEntry &&
          other.id == this.id &&
          other.workDurationMinutes == this.workDurationMinutes &&
          other.shortBreakDurationMinutes == this.shortBreakDurationMinutes &&
          other.longBreakDurationMinutes == this.longBreakDurationMinutes &&
          other.dailyGoalMinutes == this.dailyGoalMinutes &&
          other.weeklyGoalMinutes == this.weeklyGoalMinutes &&
          other.activePresetId == this.activePresetId &&
          other.autoStartNextSession == this.autoStartNextSession &&
          other.soundEnabled == this.soundEnabled &&
          other.hapticEnabled == this.hapticEnabled &&
          other.themeMode == this.themeMode);
}

class UserSettingsEntriesCompanion extends UpdateCompanion<UserSettingsEntry> {
  final Value<String> id;
  final Value<int> workDurationMinutes;
  final Value<int> shortBreakDurationMinutes;
  final Value<int> longBreakDurationMinutes;
  final Value<int> dailyGoalMinutes;
  final Value<int> weeklyGoalMinutes;
  final Value<String?> activePresetId;
  final Value<bool> autoStartNextSession;
  final Value<bool> soundEnabled;
  final Value<bool> hapticEnabled;
  final Value<String> themeMode;
  final Value<int> rowid;
  const UserSettingsEntriesCompanion({
    this.id = const Value.absent(),
    this.workDurationMinutes = const Value.absent(),
    this.shortBreakDurationMinutes = const Value.absent(),
    this.longBreakDurationMinutes = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.weeklyGoalMinutes = const Value.absent(),
    this.activePresetId = const Value.absent(),
    this.autoStartNextSession = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.hapticEnabled = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsEntriesCompanion.insert({
    required String id,
    this.workDurationMinutes = const Value.absent(),
    this.shortBreakDurationMinutes = const Value.absent(),
    this.longBreakDurationMinutes = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.weeklyGoalMinutes = const Value.absent(),
    this.activePresetId = const Value.absent(),
    this.autoStartNextSession = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.hapticEnabled = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserSettingsEntry> custom({
    Expression<String>? id,
    Expression<int>? workDurationMinutes,
    Expression<int>? shortBreakDurationMinutes,
    Expression<int>? longBreakDurationMinutes,
    Expression<int>? dailyGoalMinutes,
    Expression<int>? weeklyGoalMinutes,
    Expression<String>? activePresetId,
    Expression<bool>? autoStartNextSession,
    Expression<bool>? soundEnabled,
    Expression<bool>? hapticEnabled,
    Expression<String>? themeMode,
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
      if (weeklyGoalMinutes != null) 'weekly_goal_minutes': weeklyGoalMinutes,
      if (activePresetId != null) 'active_preset_id': activePresetId,
      if (autoStartNextSession != null)
        'auto_start_next_session': autoStartNextSession,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (hapticEnabled != null) 'haptic_enabled': hapticEnabled,
      if (themeMode != null) 'theme_mode': themeMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? workDurationMinutes,
    Value<int>? shortBreakDurationMinutes,
    Value<int>? longBreakDurationMinutes,
    Value<int>? dailyGoalMinutes,
    Value<int>? weeklyGoalMinutes,
    Value<String?>? activePresetId,
    Value<bool>? autoStartNextSession,
    Value<bool>? soundEnabled,
    Value<bool>? hapticEnabled,
    Value<String>? themeMode,
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
      weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
      activePresetId: activePresetId ?? this.activePresetId,
      autoStartNextSession: autoStartNextSession ?? this.autoStartNextSession,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      themeMode: themeMode ?? this.themeMode,
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
    if (weeklyGoalMinutes.present) {
      map['weekly_goal_minutes'] = Variable<int>(weeklyGoalMinutes.value);
    }
    if (activePresetId.present) {
      map['active_preset_id'] = Variable<String>(activePresetId.value);
    }
    if (autoStartNextSession.present) {
      map['auto_start_next_session'] = Variable<bool>(
        autoStartNextSession.value,
      );
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (hapticEnabled.present) {
      map['haptic_enabled'] = Variable<bool>(hapticEnabled.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
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
          ..write('weeklyGoalMinutes: $weeklyGoalMinutes, ')
          ..write('activePresetId: $activePresetId, ')
          ..write('autoStartNextSession: $autoStartNextSession, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('hapticEnabled: $hapticEnabled, ')
          ..write('themeMode: $themeMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerPresetEntriesTable extends TimerPresetEntries
    with TableInfo<$TimerPresetEntriesTable, TimerPresetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerPresetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
    requiredDuringInsert: true,
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
        requiredDuringInsert: true,
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
        requiredDuringInsert: true,
      );
  static const VerificationMeta _longBreakIntervalMeta = const VerificationMeta(
    'longBreakInterval',
  );
  @override
  late final GeneratedColumn<int> longBreakInterval = GeneratedColumn<int>(
    'long_break_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    workDurationMinutes,
    shortBreakDurationMinutes,
    longBreakDurationMinutes,
    longBreakInterval,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_preset_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerPresetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('work_duration_minutes')) {
      context.handle(
        _workDurationMinutesMeta,
        workDurationMinutes.isAcceptableOrUnknown(
          data['work_duration_minutes']!,
          _workDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workDurationMinutesMeta);
    }
    if (data.containsKey('short_break_duration_minutes')) {
      context.handle(
        _shortBreakDurationMinutesMeta,
        shortBreakDurationMinutes.isAcceptableOrUnknown(
          data['short_break_duration_minutes']!,
          _shortBreakDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shortBreakDurationMinutesMeta);
    }
    if (data.containsKey('long_break_duration_minutes')) {
      context.handle(
        _longBreakDurationMinutesMeta,
        longBreakDurationMinutes.isAcceptableOrUnknown(
          data['long_break_duration_minutes']!,
          _longBreakDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_longBreakDurationMinutesMeta);
    }
    if (data.containsKey('long_break_interval')) {
      context.handle(
        _longBreakIntervalMeta,
        longBreakInterval.isAcceptableOrUnknown(
          data['long_break_interval']!,
          _longBreakIntervalMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerPresetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerPresetEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
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
      longBreakInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}long_break_interval'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $TimerPresetEntriesTable createAlias(String alias) {
    return $TimerPresetEntriesTable(attachedDatabase, alias);
  }
}

class TimerPresetEntry extends DataClass
    implements Insertable<TimerPresetEntry> {
  final String id;
  final String name;
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int longBreakInterval;
  final bool isDefault;
  const TimerPresetEntry({
    required this.id,
    required this.name,
    required this.workDurationMinutes,
    required this.shortBreakDurationMinutes,
    required this.longBreakDurationMinutes,
    required this.longBreakInterval,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['work_duration_minutes'] = Variable<int>(workDurationMinutes);
    map['short_break_duration_minutes'] = Variable<int>(
      shortBreakDurationMinutes,
    );
    map['long_break_duration_minutes'] = Variable<int>(
      longBreakDurationMinutes,
    );
    map['long_break_interval'] = Variable<int>(longBreakInterval);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  TimerPresetEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimerPresetEntriesCompanion(
      id: Value(id),
      name: Value(name),
      workDurationMinutes: Value(workDurationMinutes),
      shortBreakDurationMinutes: Value(shortBreakDurationMinutes),
      longBreakDurationMinutes: Value(longBreakDurationMinutes),
      longBreakInterval: Value(longBreakInterval),
      isDefault: Value(isDefault),
    );
  }

  factory TimerPresetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerPresetEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      workDurationMinutes: serializer.fromJson<int>(
        json['workDurationMinutes'],
      ),
      shortBreakDurationMinutes: serializer.fromJson<int>(
        json['shortBreakDurationMinutes'],
      ),
      longBreakDurationMinutes: serializer.fromJson<int>(
        json['longBreakDurationMinutes'],
      ),
      longBreakInterval: serializer.fromJson<int>(json['longBreakInterval']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'workDurationMinutes': serializer.toJson<int>(workDurationMinutes),
      'shortBreakDurationMinutes': serializer.toJson<int>(
        shortBreakDurationMinutes,
      ),
      'longBreakDurationMinutes': serializer.toJson<int>(
        longBreakDurationMinutes,
      ),
      'longBreakInterval': serializer.toJson<int>(longBreakInterval),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  TimerPresetEntry copyWith({
    String? id,
    String? name,
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? longBreakInterval,
    bool? isDefault,
  }) => TimerPresetEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
    shortBreakDurationMinutes:
        shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
    longBreakDurationMinutes:
        longBreakDurationMinutes ?? this.longBreakDurationMinutes,
    longBreakInterval: longBreakInterval ?? this.longBreakInterval,
    isDefault: isDefault ?? this.isDefault,
  );
  TimerPresetEntry copyWithCompanion(TimerPresetEntriesCompanion data) {
    return TimerPresetEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      workDurationMinutes: data.workDurationMinutes.present
          ? data.workDurationMinutes.value
          : this.workDurationMinutes,
      shortBreakDurationMinutes: data.shortBreakDurationMinutes.present
          ? data.shortBreakDurationMinutes.value
          : this.shortBreakDurationMinutes,
      longBreakDurationMinutes: data.longBreakDurationMinutes.present
          ? data.longBreakDurationMinutes.value
          : this.longBreakDurationMinutes,
      longBreakInterval: data.longBreakInterval.present
          ? data.longBreakInterval.value
          : this.longBreakInterval,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerPresetEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('workDurationMinutes: $workDurationMinutes, ')
          ..write('shortBreakDurationMinutes: $shortBreakDurationMinutes, ')
          ..write('longBreakDurationMinutes: $longBreakDurationMinutes, ')
          ..write('longBreakInterval: $longBreakInterval, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    workDurationMinutes,
    shortBreakDurationMinutes,
    longBreakDurationMinutes,
    longBreakInterval,
    isDefault,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerPresetEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.workDurationMinutes == this.workDurationMinutes &&
          other.shortBreakDurationMinutes == this.shortBreakDurationMinutes &&
          other.longBreakDurationMinutes == this.longBreakDurationMinutes &&
          other.longBreakInterval == this.longBreakInterval &&
          other.isDefault == this.isDefault);
}

class TimerPresetEntriesCompanion extends UpdateCompanion<TimerPresetEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> workDurationMinutes;
  final Value<int> shortBreakDurationMinutes;
  final Value<int> longBreakDurationMinutes;
  final Value<int> longBreakInterval;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const TimerPresetEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.workDurationMinutes = const Value.absent(),
    this.shortBreakDurationMinutes = const Value.absent(),
    this.longBreakDurationMinutes = const Value.absent(),
    this.longBreakInterval = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimerPresetEntriesCompanion.insert({
    required String id,
    required String name,
    required int workDurationMinutes,
    required int shortBreakDurationMinutes,
    required int longBreakDurationMinutes,
    this.longBreakInterval = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       workDurationMinutes = Value(workDurationMinutes),
       shortBreakDurationMinutes = Value(shortBreakDurationMinutes),
       longBreakDurationMinutes = Value(longBreakDurationMinutes);
  static Insertable<TimerPresetEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? workDurationMinutes,
    Expression<int>? shortBreakDurationMinutes,
    Expression<int>? longBreakDurationMinutes,
    Expression<int>? longBreakInterval,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (workDurationMinutes != null)
        'work_duration_minutes': workDurationMinutes,
      if (shortBreakDurationMinutes != null)
        'short_break_duration_minutes': shortBreakDurationMinutes,
      if (longBreakDurationMinutes != null)
        'long_break_duration_minutes': longBreakDurationMinutes,
      if (longBreakInterval != null) 'long_break_interval': longBreakInterval,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimerPresetEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? workDurationMinutes,
    Value<int>? shortBreakDurationMinutes,
    Value<int>? longBreakDurationMinutes,
    Value<int>? longBreakInterval,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return TimerPresetEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    if (longBreakInterval.present) {
      map['long_break_interval'] = Variable<int>(longBreakInterval.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerPresetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('workDurationMinutes: $workDurationMinutes, ')
          ..write('shortBreakDurationMinutes: $shortBreakDurationMinutes, ')
          ..write('longBreakDurationMinutes: $longBreakDurationMinutes, ')
          ..write('longBreakInterval: $longBreakInterval, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TaskEntriesTable taskEntries = $TaskEntriesTable(this);
  late final $SubtaskEntriesTable subtaskEntries = $SubtaskEntriesTable(this);
  late final $FocusSessionEntriesTable focusSessionEntries =
      $FocusSessionEntriesTable(this);
  late final $UserSettingsEntriesTable userSettingsEntries =
      $UserSettingsEntriesTable(this);
  late final $TimerPresetEntriesTable timerPresetEntries =
      $TimerPresetEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    taskEntries,
    subtaskEntries,
    focusSessionEntries,
    userSettingsEntries,
    timerPresetEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'task_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('subtask_entries', kind: UpdateKind.delete)],
    ),
  ]);
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
      Value<String?> category,
      Value<String> tags,
      Value<int?> estimatedMinutes,
      Value<int> actualMinutes,
      Value<String?> recurrenceRule,
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
      Value<String?> category,
      Value<String> tags,
      Value<int?> estimatedMinutes,
      Value<int> actualMinutes,
      Value<String?> recurrenceRule,
      Value<int> rowid,
    });

final class $$TaskEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $TaskEntriesTable, TaskEntry> {
  $$TaskEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubtaskEntriesTable, List<SubtaskEntry>>
  _subtaskEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subtaskEntries,
    aliasName: 'task_entries__id__subtask_entries__task_id',
  );

  $$SubtaskEntriesTableProcessedTableManager get subtaskEntriesRefs {
    final manager = $$SubtaskEntriesTableTableManager(
      $_db,
      $_db.subtaskEntries,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtaskEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subtaskEntriesRefs(
    Expression<bool> Function($$SubtaskEntriesTableFilterComposer f) f,
  ) {
    final $$SubtaskEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtaskEntries,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtaskEntriesTableFilterComposer(
            $db: $db,
            $table: $db.subtaskEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  Expression<T> subtaskEntriesRefs<T extends Object>(
    Expression<T> Function($$SubtaskEntriesTableAnnotationComposer a) f,
  ) {
    final $$SubtaskEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtaskEntries,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtaskEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.subtaskEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (TaskEntry, $$TaskEntriesTableReferences),
          TaskEntry,
          PrefetchHooks Function({bool subtaskEntriesRefs})
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
                Value<String?> category = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<int> actualMinutes = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
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
                category: category,
                tags: tags,
                estimatedMinutes: estimatedMinutes,
                actualMinutes: actualMinutes,
                recurrenceRule: recurrenceRule,
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
                Value<String?> category = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<int> actualMinutes = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
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
                category: category,
                tags: tags,
                estimatedMinutes: estimatedMinutes,
                actualMinutes: actualMinutes,
                recurrenceRule: recurrenceRule,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskEntriesTable, TaskEntry>(table),
                  $$TaskEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subtaskEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subtaskEntriesRefs) db.subtaskEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subtaskEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      TaskEntry,
                      $TaskEntriesTable,
                      SubtaskEntry,
                      $SubtaskEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$TaskEntriesTableReferences
                          ._subtaskEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TaskEntriesTableReferences(
                            db,
                            table,
                            p0,
                          ).subtaskEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'task_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (TaskEntry, $$TaskEntriesTableReferences),
      TaskEntry,
      PrefetchHooks Function({bool subtaskEntriesRefs})
    >;
typedef $$SubtaskEntriesTableCreateCompanionBuilder =
    SubtaskEntriesCompanion Function({
      required String id,
      required String taskId,
      required String title,
      Value<bool> isCompleted,
      Value<int> orderIndex,
      Value<int> rowid,
    });
typedef $$SubtaskEntriesTableUpdateCompanionBuilder =
    SubtaskEntriesCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> title,
      Value<bool> isCompleted,
      Value<int> orderIndex,
      Value<int> rowid,
    });

final class $$SubtaskEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $SubtaskEntriesTable, SubtaskEntry> {
  $$SubtaskEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TaskEntriesTable _taskIdTable(_$AppDatabase db) =>
      db.taskEntries.createAlias('subtask_entries__task_id__task_entries__id');

  $$TaskEntriesTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TaskEntriesTableTableManager(
      $_db,
      $_db.taskEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubtaskEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SubtaskEntriesTable> {
  $$SubtaskEntriesTableFilterComposer({
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

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$TaskEntriesTableFilterComposer get taskId {
    final $$TaskEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskEntriesTableFilterComposer(
            $db: $db,
            $table: $db.taskEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtaskEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtaskEntriesTable> {
  $$SubtaskEntriesTableOrderingComposer({
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

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$TaskEntriesTableOrderingComposer get taskId {
    final $$TaskEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.taskEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtaskEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtaskEntriesTable> {
  $$SubtaskEntriesTableAnnotationComposer({
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

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$TaskEntriesTableAnnotationComposer get taskId {
    final $$TaskEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtaskEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubtaskEntriesTable,
          SubtaskEntry,
          $$SubtaskEntriesTableFilterComposer,
          $$SubtaskEntriesTableOrderingComposer,
          $$SubtaskEntriesTableAnnotationComposer,
          $$SubtaskEntriesTableCreateCompanionBuilder,
          $$SubtaskEntriesTableUpdateCompanionBuilder,
          (SubtaskEntry, $$SubtaskEntriesTableReferences),
          SubtaskEntry,
          PrefetchHooks Function({bool taskId})
        > {
  $$SubtaskEntriesTableTableManager(
    _$AppDatabase db,
    $SubtaskEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtaskEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtaskEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtaskEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubtaskEntriesCompanion(
                id: id,
                taskId: taskId,
                title: title,
                isCompleted: isCompleted,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String title,
                Value<bool> isCompleted = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubtaskEntriesCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                isCompleted: isCompleted,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubtaskEntriesTable, SubtaskEntry>(table),
                  $$SubtaskEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$SubtaskEntriesTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$SubtaskEntriesTableReferences
                            ._taskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubtaskEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubtaskEntriesTable,
      SubtaskEntry,
      $$SubtaskEntriesTableFilterComposer,
      $$SubtaskEntriesTableOrderingComposer,
      $$SubtaskEntriesTableAnnotationComposer,
      $$SubtaskEntriesTableCreateCompanionBuilder,
      $$SubtaskEntriesTableUpdateCompanionBuilder,
      (SubtaskEntry, $$SubtaskEntriesTableReferences),
      SubtaskEntry,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$FocusSessionEntriesTableCreateCompanionBuilder =
    FocusSessionEntriesCompanion Function({
      required String id,
      required String mode,
      required int durationSeconds,
      required DateTime completedAt,
      Value<String?> taskId,
      Value<int> distractionCount,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$FocusSessionEntriesTableUpdateCompanionBuilder =
    FocusSessionEntriesCompanion Function({
      Value<String> id,
      Value<String> mode,
      Value<int> durationSeconds,
      Value<DateTime> completedAt,
      Value<String?> taskId,
      Value<int> distractionCount,
      Value<String> status,
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

  ColumnFilters<int> get distractionCount => $composableBuilder(
    column: $table.distractionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<int> get distractionCount => $composableBuilder(
    column: $table.distractionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  GeneratedColumn<int> get distractionCount => $composableBuilder(
    column: $table.distractionCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
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
                Value<int> distractionCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionEntriesCompanion(
                id: id,
                mode: mode,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
                taskId: taskId,
                distractionCount: distractionCount,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mode,
                required int durationSeconds,
                required DateTime completedAt,
                Value<String?> taskId = const Value.absent(),
                Value<int> distractionCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionEntriesCompanion.insert(
                id: id,
                mode: mode,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
                taskId: taskId,
                distractionCount: distractionCount,
                status: status,
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
      Value<int> weeklyGoalMinutes,
      Value<String?> activePresetId,
      Value<bool> autoStartNextSession,
      Value<bool> soundEnabled,
      Value<bool> hapticEnabled,
      Value<String> themeMode,
      Value<int> rowid,
    });
typedef $$UserSettingsEntriesTableUpdateCompanionBuilder =
    UserSettingsEntriesCompanion Function({
      Value<String> id,
      Value<int> workDurationMinutes,
      Value<int> shortBreakDurationMinutes,
      Value<int> longBreakDurationMinutes,
      Value<int> dailyGoalMinutes,
      Value<int> weeklyGoalMinutes,
      Value<String?> activePresetId,
      Value<bool> autoStartNextSession,
      Value<bool> soundEnabled,
      Value<bool> hapticEnabled,
      Value<String> themeMode,
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

  ColumnFilters<int> get weeklyGoalMinutes => $composableBuilder(
    column: $table.weeklyGoalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activePresetId => $composableBuilder(
    column: $table.activePresetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoStartNextSession => $composableBuilder(
    column: $table.autoStartNextSession,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hapticEnabled => $composableBuilder(
    column: $table.hapticEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
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

  ColumnOrderings<int> get weeklyGoalMinutes => $composableBuilder(
    column: $table.weeklyGoalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activePresetId => $composableBuilder(
    column: $table.activePresetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoStartNextSession => $composableBuilder(
    column: $table.autoStartNextSession,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hapticEnabled => $composableBuilder(
    column: $table.hapticEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
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

  GeneratedColumn<int> get weeklyGoalMinutes => $composableBuilder(
    column: $table.weeklyGoalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activePresetId => $composableBuilder(
    column: $table.activePresetId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoStartNextSession => $composableBuilder(
    column: $table.autoStartNextSession,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hapticEnabled => $composableBuilder(
    column: $table.hapticEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);
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
                Value<int> weeklyGoalMinutes = const Value.absent(),
                Value<String?> activePresetId = const Value.absent(),
                Value<bool> autoStartNextSession = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> hapticEnabled = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsEntriesCompanion(
                id: id,
                workDurationMinutes: workDurationMinutes,
                shortBreakDurationMinutes: shortBreakDurationMinutes,
                longBreakDurationMinutes: longBreakDurationMinutes,
                dailyGoalMinutes: dailyGoalMinutes,
                weeklyGoalMinutes: weeklyGoalMinutes,
                activePresetId: activePresetId,
                autoStartNextSession: autoStartNextSession,
                soundEnabled: soundEnabled,
                hapticEnabled: hapticEnabled,
                themeMode: themeMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> workDurationMinutes = const Value.absent(),
                Value<int> shortBreakDurationMinutes = const Value.absent(),
                Value<int> longBreakDurationMinutes = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<int> weeklyGoalMinutes = const Value.absent(),
                Value<String?> activePresetId = const Value.absent(),
                Value<bool> autoStartNextSession = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> hapticEnabled = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsEntriesCompanion.insert(
                id: id,
                workDurationMinutes: workDurationMinutes,
                shortBreakDurationMinutes: shortBreakDurationMinutes,
                longBreakDurationMinutes: longBreakDurationMinutes,
                dailyGoalMinutes: dailyGoalMinutes,
                weeklyGoalMinutes: weeklyGoalMinutes,
                activePresetId: activePresetId,
                autoStartNextSession: autoStartNextSession,
                soundEnabled: soundEnabled,
                hapticEnabled: hapticEnabled,
                themeMode: themeMode,
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
typedef $$TimerPresetEntriesTableCreateCompanionBuilder =
    TimerPresetEntriesCompanion Function({
      required String id,
      required String name,
      required int workDurationMinutes,
      required int shortBreakDurationMinutes,
      required int longBreakDurationMinutes,
      Value<int> longBreakInterval,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$TimerPresetEntriesTableUpdateCompanionBuilder =
    TimerPresetEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> workDurationMinutes,
      Value<int> shortBreakDurationMinutes,
      Value<int> longBreakDurationMinutes,
      Value<int> longBreakInterval,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$TimerPresetEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimerPresetEntriesTable> {
  $$TimerPresetEntriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnFilters<int> get longBreakInterval => $composableBuilder(
    column: $table.longBreakInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimerPresetEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerPresetEntriesTable> {
  $$TimerPresetEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<int> get longBreakInterval => $composableBuilder(
    column: $table.longBreakInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerPresetEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerPresetEntriesTable> {
  $$TimerPresetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

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

  GeneratedColumn<int> get longBreakInterval => $composableBuilder(
    column: $table.longBreakInterval,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$TimerPresetEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerPresetEntriesTable,
          TimerPresetEntry,
          $$TimerPresetEntriesTableFilterComposer,
          $$TimerPresetEntriesTableOrderingComposer,
          $$TimerPresetEntriesTableAnnotationComposer,
          $$TimerPresetEntriesTableCreateCompanionBuilder,
          $$TimerPresetEntriesTableUpdateCompanionBuilder,
          (
            TimerPresetEntry,
            BaseReferences<
              _$AppDatabase,
              $TimerPresetEntriesTable,
              TimerPresetEntry
            >,
          ),
          TimerPresetEntry,
          PrefetchHooks Function()
        > {
  $$TimerPresetEntriesTableTableManager(
    _$AppDatabase db,
    $TimerPresetEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerPresetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerPresetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerPresetEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> workDurationMinutes = const Value.absent(),
                Value<int> shortBreakDurationMinutes = const Value.absent(),
                Value<int> longBreakDurationMinutes = const Value.absent(),
                Value<int> longBreakInterval = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerPresetEntriesCompanion(
                id: id,
                name: name,
                workDurationMinutes: workDurationMinutes,
                shortBreakDurationMinutes: shortBreakDurationMinutes,
                longBreakDurationMinutes: longBreakDurationMinutes,
                longBreakInterval: longBreakInterval,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int workDurationMinutes,
                required int shortBreakDurationMinutes,
                required int longBreakDurationMinutes,
                Value<int> longBreakInterval = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerPresetEntriesCompanion.insert(
                id: id,
                name: name,
                workDurationMinutes: workDurationMinutes,
                shortBreakDurationMinutes: shortBreakDurationMinutes,
                longBreakDurationMinutes: longBreakDurationMinutes,
                longBreakInterval: longBreakInterval,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerPresetEntriesTable, TimerPresetEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TimerPresetEntriesTable,
                    TimerPresetEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimerPresetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerPresetEntriesTable,
      TimerPresetEntry,
      $$TimerPresetEntriesTableFilterComposer,
      $$TimerPresetEntriesTableOrderingComposer,
      $$TimerPresetEntriesTableAnnotationComposer,
      $$TimerPresetEntriesTableCreateCompanionBuilder,
      $$TimerPresetEntriesTableUpdateCompanionBuilder,
      (
        TimerPresetEntry,
        BaseReferences<
          _$AppDatabase,
          $TimerPresetEntriesTable,
          TimerPresetEntry
        >,
      ),
      TimerPresetEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TaskEntriesTableTableManager get taskEntries =>
      $$TaskEntriesTableTableManager(_db, _db.taskEntries);
  $$SubtaskEntriesTableTableManager get subtaskEntries =>
      $$SubtaskEntriesTableTableManager(_db, _db.subtaskEntries);
  $$FocusSessionEntriesTableTableManager get focusSessionEntries =>
      $$FocusSessionEntriesTableTableManager(_db, _db.focusSessionEntries);
  $$UserSettingsEntriesTableTableManager get userSettingsEntries =>
      $$UserSettingsEntriesTableTableManager(_db, _db.userSettingsEntries);
  $$TimerPresetEntriesTableTableManager get timerPresetEntries =>
      $$TimerPresetEntriesTableTableManager(_db, _db.timerPresetEntries);
}
