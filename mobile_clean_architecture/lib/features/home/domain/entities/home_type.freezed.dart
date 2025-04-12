// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HomeTypeEntity _$HomeTypeEntityFromJson(Map<String, dynamic> json) {
  return _$HomeTypeEntityImpl.fromJson(json);
}

/// @nodoc
mixin _$HomeTypeEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get route => throw _privateConstructorUsedError;

  /// Serializes this HomeTypeEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeTypeEntityCopyWith<HomeTypeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeTypeEntityCopyWith<$Res> {
  factory $HomeTypeEntityCopyWith(
          HomeTypeEntity value, $Res Function(HomeTypeEntity) then) =
      _$HomeTypeEntityCopyWithImpl<$Res, HomeTypeEntity>;
  @useResult
  $Res call(
      {String id, String title, String description, String icon, String route});
}

/// @nodoc
class _$HomeTypeEntityCopyWithImpl<$Res, $Val extends HomeTypeEntity>
    implements $HomeTypeEntityCopyWith<$Res> {
  _$HomeTypeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? route = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      route: null == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$$HomeTypeEntityImplImplCopyWith<$Res>
    implements $HomeTypeEntityCopyWith<$Res> {
  factory _$$$HomeTypeEntityImplImplCopyWith(_$$HomeTypeEntityImplImpl value,
          $Res Function(_$$HomeTypeEntityImplImpl) then) =
      __$$$HomeTypeEntityImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String title, String description, String icon, String route});
}

/// @nodoc
class __$$$HomeTypeEntityImplImplCopyWithImpl<$Res>
    extends _$HomeTypeEntityCopyWithImpl<$Res, _$$HomeTypeEntityImplImpl>
    implements _$$$HomeTypeEntityImplImplCopyWith<$Res> {
  __$$$HomeTypeEntityImplImplCopyWithImpl(_$$HomeTypeEntityImplImpl _value,
      $Res Function(_$$HomeTypeEntityImplImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomeTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? route = null,
  }) {
    return _then(_$$HomeTypeEntityImplImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      route: null == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$$HomeTypeEntityImplImpl implements _$HomeTypeEntityImpl {
  const _$$HomeTypeEntityImplImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.icon,
      required this.route});

  factory _$$HomeTypeEntityImplImpl.fromJson(Map<String, dynamic> json) =>
      _$$$HomeTypeEntityImplImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String icon;
  @override
  final String route;

  @override
  String toString() {
    return 'HomeTypeEntity(id: $id, title: $title, description: $description, icon: $icon, route: $route)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$HomeTypeEntityImplImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.route, route) || other.route == route));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, description, icon, route);

  /// Create a copy of HomeTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$$HomeTypeEntityImplImplCopyWith<_$$HomeTypeEntityImplImpl> get copyWith =>
      __$$$HomeTypeEntityImplImplCopyWithImpl<_$$HomeTypeEntityImplImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$$HomeTypeEntityImplImplToJson(
      this,
    );
  }
}

abstract class _$HomeTypeEntityImpl implements HomeTypeEntity {
  const factory _$HomeTypeEntityImpl(
      {required final String id,
      required final String title,
      required final String description,
      required final String icon,
      required final String route}) = _$$HomeTypeEntityImplImpl;

  factory _$HomeTypeEntityImpl.fromJson(Map<String, dynamic> json) =
      _$$HomeTypeEntityImplImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get icon;
  @override
  String get route;

  /// Create a copy of HomeTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$$HomeTypeEntityImplImplCopyWith<_$$HomeTypeEntityImplImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
