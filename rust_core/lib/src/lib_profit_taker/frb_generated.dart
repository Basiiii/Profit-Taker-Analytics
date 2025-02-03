// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.7.1.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.dart';
import 'frb_generated.io.dart'
    if (dart.library.js_interop) 'frb_generated.web.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Main entrypoint of the Rust API
class RustLib extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  @internal
  static final instance = RustLib._();

  RustLib._();

  /// Initialize flutter_rust_bridge
  static Future<void> init({
    RustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
  }) async {
    await instance.initImpl(
      api: api,
      handler: handler,
      externalLibrary: externalLibrary,
    );
  }

  /// Initialize flutter_rust_bridge in mock mode.
  /// No libraries for FFI are loaded.
  static void initMock({
    required RustLibApi api,
  }) {
    instance.initMockImpl(
      api: api,
    );
  }

  /// Dispose flutter_rust_bridge
  ///
  /// The call to this function is optional, since flutter_rust_bridge (and everything else)
  /// is automatically disposed when the app stops.
  static void dispose() => instance.disposeImpl();

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor =>
      RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor =>
      RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.crateApiInitApp();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      kDefaultExternalLibraryLoaderConfig;

  @override
  String get codegenVersion => '2.7.1';

  @override
  int get rustContentHash => -137613692;

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
    stem: 'lib_profit_taker',
    ioDirectory: 'lib_profit_taker/target/release/',
    webPrefix: 'pkg/',
  );
}

abstract class RustLibApi extends BaseApi {
  bool crateApiCheckIfLatestRun({required int runId});

  bool crateApiCheckRunExists({required int runId});

  DeleteRunResult crateApiDeleteRunFromDb({required int runId});

  int? crateApiGetEarliestRunId();

  int? crateApiGetLatestRunId();

  int? crateApiGetNextRunId({required int currentRunId});

  int? crateApiGetPreviousRunId({required int currentRunId});

  RunModel crateApiGetRunFromDb({required int runId});

  Future<void> crateApiInitApp();

  void crateApiInitializeDb({required String path});

  bool crateApiMarkRunAsFavorite({required int runId});

  bool crateApiRemoveRunFromFavorites({required int runId});
}

class RustLibApiImpl extends RustLibApiImplPlatform implements RustLibApi {
  RustLibApiImpl({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @override
  bool crateApiCheckIfLatestRun({required int runId}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(runId, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 1)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_bool,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiCheckIfLatestRunConstMeta,
      argValues: [runId],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiCheckIfLatestRunConstMeta => const TaskConstMeta(
        debugName: "check_if_latest_run",
        argNames: ["runId"],
      );

  @override
  bool crateApiCheckRunExists({required int runId}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(runId, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 2)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_bool,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiCheckRunExistsConstMeta,
      argValues: [runId],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiCheckRunExistsConstMeta => const TaskConstMeta(
        debugName: "check_run_exists",
        argNames: ["runId"],
      );

  @override
  DeleteRunResult crateApiDeleteRunFromDb({required int runId}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(runId, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 3)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_delete_run_result,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiDeleteRunFromDbConstMeta,
      argValues: [runId],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiDeleteRunFromDbConstMeta => const TaskConstMeta(
        debugName: "delete_run_from_db",
        argNames: ["runId"],
      );

  @override
  int? crateApiGetEarliestRunId() {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 4)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_opt_box_autoadd_i_32,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiGetEarliestRunIdConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiGetEarliestRunIdConstMeta => const TaskConstMeta(
        debugName: "get_earliest_run_id",
        argNames: [],
      );

  @override
  int? crateApiGetLatestRunId() {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 5)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_opt_box_autoadd_i_32,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiGetLatestRunIdConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiGetLatestRunIdConstMeta => const TaskConstMeta(
        debugName: "get_latest_run_id",
        argNames: [],
      );

  @override
  int? crateApiGetNextRunId({required int currentRunId}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(currentRunId, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 6)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_opt_box_autoadd_i_32,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiGetNextRunIdConstMeta,
      argValues: [currentRunId],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiGetNextRunIdConstMeta => const TaskConstMeta(
        debugName: "get_next_run_id",
        argNames: ["currentRunId"],
      );

  @override
  int? crateApiGetPreviousRunId({required int currentRunId}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(currentRunId, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 7)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_opt_box_autoadd_i_32,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiGetPreviousRunIdConstMeta,
      argValues: [currentRunId],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiGetPreviousRunIdConstMeta => const TaskConstMeta(
        debugName: "get_previous_run_id",
        argNames: ["currentRunId"],
      );

  @override
  RunModel crateApiGetRunFromDb({required int runId}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(runId, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 8)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_run_model,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiGetRunFromDbConstMeta,
      argValues: [runId],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiGetRunFromDbConstMeta => const TaskConstMeta(
        debugName: "get_run_from_db",
        argNames: ["runId"],
      );

  @override
  Future<void> crateApiInitApp() {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 9, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiInitAppConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiInitAppConstMeta => const TaskConstMeta(
        debugName: "init_app",
        argNames: [],
      );

  @override
  void crateApiInitializeDb({required String path}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_String(path, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 10)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiInitializeDbConstMeta,
      argValues: [path],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiInitializeDbConstMeta => const TaskConstMeta(
        debugName: "initialize_db",
        argNames: ["path"],
      );

  @override
  bool crateApiMarkRunAsFavorite({required int runId}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(runId, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 11)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_bool,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiMarkRunAsFavoriteConstMeta,
      argValues: [runId],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiMarkRunAsFavoriteConstMeta => const TaskConstMeta(
        debugName: "mark_run_as_favorite",
        argNames: ["runId"],
      );

  @override
  bool crateApiRemoveRunFromFavorites({required int runId}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_i_32(runId, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 12)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_bool,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiRemoveRunFromFavoritesConstMeta,
      argValues: [runId],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRemoveRunFromFavoritesConstMeta =>
      const TaskConstMeta(
        debugName: "remove_run_from_favorites",
        argNames: ["runId"],
      );

  @protected
  String dco_decode_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as String;
  }

  @protected
  bool dco_decode_bool(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as bool;
  }

  @protected
  int dco_decode_box_autoadd_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  DeleteRunResult dco_decode_delete_run_result(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return DeleteRunResult(
      success: dco_decode_bool(arr[0]),
      error: dco_decode_opt_String(arr[1]),
    );
  }

  @protected
  double dco_decode_f_64(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as double;
  }

  @protected
  int dco_decode_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  PlatformInt64 dco_decode_i_64(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeI64(raw);
  }

  @protected
  LegBreakModel dco_decode_leg_break_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 3)
      throw Exception('unexpected arr length: expect 3 but see ${arr.length}');
    return LegBreakModel(
      legBreakTime: dco_decode_f_64(arr[0]),
      legPosition: dco_decode_leg_position_enum(arr[1]),
      legOrder: dco_decode_i_32(arr[2]),
    );
  }

  @protected
  LegPositionEnum dco_decode_leg_position_enum(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return LegPositionEnum.values[raw as int];
  }

  @protected
  List<LegBreakModel> dco_decode_list_leg_break_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_leg_break_model).toList();
  }

  @protected
  List<PhaseModel> dco_decode_list_phase_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_phase_model).toList();
  }

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Uint8List;
  }

  @protected
  List<ShieldChangeModel> dco_decode_list_shield_change_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_shield_change_model).toList();
  }

  @protected
  List<SquadMemberModel> dco_decode_list_squad_member_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_squad_member_model).toList();
  }

  @protected
  String? dco_decode_opt_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_String(raw);
  }

  @protected
  int? dco_decode_opt_box_autoadd_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_box_autoadd_i_32(raw);
  }

  @protected
  PhaseModel dco_decode_phase_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 8)
      throw Exception('unexpected arr length: expect 8 but see ${arr.length}');
    return PhaseModel(
      phaseNumber: dco_decode_i_32(arr[0]),
      totalTime: dco_decode_f_64(arr[1]),
      totalShieldTime: dco_decode_f_64(arr[2]),
      totalLegTime: dco_decode_f_64(arr[3]),
      totalBodyKillTime: dco_decode_f_64(arr[4]),
      totalPylonTime: dco_decode_f_64(arr[5]),
      shieldChanges: dco_decode_list_shield_change_model(arr[6]),
      legBreaks: dco_decode_list_leg_break_model(arr[7]),
    );
  }

  @protected
  RunModel dco_decode_run_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 10)
      throw Exception('unexpected arr length: expect 10 but see ${arr.length}');
    return RunModel(
      runId: dco_decode_i_32(arr[0]),
      timeStamp: dco_decode_i_64(arr[1]),
      runName: dco_decode_String(arr[2]),
      playerName: dco_decode_String(arr[3]),
      isBuggedRun: dco_decode_bool(arr[4]),
      isAbortedRun: dco_decode_bool(arr[5]),
      isSoloRun: dco_decode_bool(arr[6]),
      totalTimes: dco_decode_total_times_model(arr[7]),
      phases: dco_decode_list_phase_model(arr[8]),
      squadMembers: dco_decode_list_squad_member_model(arr[9]),
    );
  }

  @protected
  ShieldChangeModel dco_decode_shield_change_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return ShieldChangeModel(
      shieldTime: dco_decode_f_64(arr[0]),
      statusEffect: dco_decode_status_effect_enum(arr[1]),
    );
  }

  @protected
  SquadMemberModel dco_decode_squad_member_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 1)
      throw Exception('unexpected arr length: expect 1 but see ${arr.length}');
    return SquadMemberModel(
      memberName: dco_decode_String(arr[0]),
    );
  }

  @protected
  StatusEffectEnum dco_decode_status_effect_enum(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return StatusEffectEnum.values[raw as int];
  }

  @protected
  TotalTimesModel dco_decode_total_times_model(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 6)
      throw Exception('unexpected arr length: expect 6 but see ${arr.length}');
    return TotalTimesModel(
      totalDuration: dco_decode_f_64(arr[0]),
      totalFlightTime: dco_decode_f_64(arr[1]),
      totalShieldTime: dco_decode_f_64(arr[2]),
      totalLegTime: dco_decode_f_64(arr[3]),
      totalBodyTime: dco_decode_f_64(arr[4]),
      totalPylonTime: dco_decode_f_64(arr[5]),
    );
  }

  @protected
  int dco_decode_u_8(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  void dco_decode_unit(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return;
  }

  @protected
  String sse_decode_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_list_prim_u_8_strict(deserializer);
    return utf8.decoder.convert(inner);
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  int sse_decode_box_autoadd_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_i_32(deserializer));
  }

  @protected
  DeleteRunResult sse_decode_delete_run_result(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_success = sse_decode_bool(deserializer);
    var var_error = sse_decode_opt_String(deserializer);
    return DeleteRunResult(success: var_success, error: var_error);
  }

  @protected
  double sse_decode_f_64(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getFloat64();
  }

  @protected
  int sse_decode_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getInt32();
  }

  @protected
  PlatformInt64 sse_decode_i_64(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getPlatformInt64();
  }

  @protected
  LegBreakModel sse_decode_leg_break_model(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_legBreakTime = sse_decode_f_64(deserializer);
    var var_legPosition = sse_decode_leg_position_enum(deserializer);
    var var_legOrder = sse_decode_i_32(deserializer);
    return LegBreakModel(
        legBreakTime: var_legBreakTime,
        legPosition: var_legPosition,
        legOrder: var_legOrder);
  }

  @protected
  LegPositionEnum sse_decode_leg_position_enum(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_i_32(deserializer);
    return LegPositionEnum.values[inner];
  }

  @protected
  List<LegBreakModel> sse_decode_list_leg_break_model(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <LegBreakModel>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_leg_break_model(deserializer));
    }
    return ans_;
  }

  @protected
  List<PhaseModel> sse_decode_list_phase_model(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <PhaseModel>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_phase_model(deserializer));
    }
    return ans_;
  }

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint8List(len_);
  }

  @protected
  List<ShieldChangeModel> sse_decode_list_shield_change_model(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <ShieldChangeModel>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_shield_change_model(deserializer));
    }
    return ans_;
  }

  @protected
  List<SquadMemberModel> sse_decode_list_squad_member_model(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <SquadMemberModel>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_squad_member_model(deserializer));
    }
    return ans_;
  }

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_String(deserializer));
    } else {
      return null;
    }
  }

  @protected
  int? sse_decode_opt_box_autoadd_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_box_autoadd_i_32(deserializer));
    } else {
      return null;
    }
  }

  @protected
  PhaseModel sse_decode_phase_model(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_phaseNumber = sse_decode_i_32(deserializer);
    var var_totalTime = sse_decode_f_64(deserializer);
    var var_totalShieldTime = sse_decode_f_64(deserializer);
    var var_totalLegTime = sse_decode_f_64(deserializer);
    var var_totalBodyKillTime = sse_decode_f_64(deserializer);
    var var_totalPylonTime = sse_decode_f_64(deserializer);
    var var_shieldChanges = sse_decode_list_shield_change_model(deserializer);
    var var_legBreaks = sse_decode_list_leg_break_model(deserializer);
    return PhaseModel(
        phaseNumber: var_phaseNumber,
        totalTime: var_totalTime,
        totalShieldTime: var_totalShieldTime,
        totalLegTime: var_totalLegTime,
        totalBodyKillTime: var_totalBodyKillTime,
        totalPylonTime: var_totalPylonTime,
        shieldChanges: var_shieldChanges,
        legBreaks: var_legBreaks);
  }

  @protected
  RunModel sse_decode_run_model(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_runId = sse_decode_i_32(deserializer);
    var var_timeStamp = sse_decode_i_64(deserializer);
    var var_runName = sse_decode_String(deserializer);
    var var_playerName = sse_decode_String(deserializer);
    var var_isBuggedRun = sse_decode_bool(deserializer);
    var var_isAbortedRun = sse_decode_bool(deserializer);
    var var_isSoloRun = sse_decode_bool(deserializer);
    var var_totalTimes = sse_decode_total_times_model(deserializer);
    var var_phases = sse_decode_list_phase_model(deserializer);
    var var_squadMembers = sse_decode_list_squad_member_model(deserializer);
    return RunModel(
        runId: var_runId,
        timeStamp: var_timeStamp,
        runName: var_runName,
        playerName: var_playerName,
        isBuggedRun: var_isBuggedRun,
        isAbortedRun: var_isAbortedRun,
        isSoloRun: var_isSoloRun,
        totalTimes: var_totalTimes,
        phases: var_phases,
        squadMembers: var_squadMembers);
  }

  @protected
  ShieldChangeModel sse_decode_shield_change_model(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_shieldTime = sse_decode_f_64(deserializer);
    var var_statusEffect = sse_decode_status_effect_enum(deserializer);
    return ShieldChangeModel(
        shieldTime: var_shieldTime, statusEffect: var_statusEffect);
  }

  @protected
  SquadMemberModel sse_decode_squad_member_model(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_memberName = sse_decode_String(deserializer);
    return SquadMemberModel(memberName: var_memberName);
  }

  @protected
  StatusEffectEnum sse_decode_status_effect_enum(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_i_32(deserializer);
    return StatusEffectEnum.values[inner];
  }

  @protected
  TotalTimesModel sse_decode_total_times_model(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_totalDuration = sse_decode_f_64(deserializer);
    var var_totalFlightTime = sse_decode_f_64(deserializer);
    var var_totalShieldTime = sse_decode_f_64(deserializer);
    var var_totalLegTime = sse_decode_f_64(deserializer);
    var var_totalBodyTime = sse_decode_f_64(deserializer);
    var var_totalPylonTime = sse_decode_f_64(deserializer);
    return TotalTimesModel(
        totalDuration: var_totalDuration,
        totalFlightTime: var_totalFlightTime,
        totalShieldTime: var_totalShieldTime,
        totalLegTime: var_totalLegTime,
        totalBodyTime: var_totalBodyTime,
        totalPylonTime: var_totalPylonTime);
  }

  @protected
  int sse_decode_u_8(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8();
  }

  @protected
  void sse_decode_unit(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  void sse_encode_String(String self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_prim_u_8_strict(utf8.encoder.convert(self), serializer);
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self ? 1 : 0);
  }

  @protected
  void sse_encode_box_autoadd_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self, serializer);
  }

  @protected
  void sse_encode_delete_run_result(
      DeleteRunResult self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_bool(self.success, serializer);
    sse_encode_opt_String(self.error, serializer);
  }

  @protected
  void sse_encode_f_64(double self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putFloat64(self);
  }

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putInt32(self);
  }

  @protected
  void sse_encode_i_64(PlatformInt64 self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putPlatformInt64(self);
  }

  @protected
  void sse_encode_leg_break_model(
      LegBreakModel self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_f_64(self.legBreakTime, serializer);
    sse_encode_leg_position_enum(self.legPosition, serializer);
    sse_encode_i_32(self.legOrder, serializer);
  }

  @protected
  void sse_encode_leg_position_enum(
      LegPositionEnum self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.index, serializer);
  }

  @protected
  void sse_encode_list_leg_break_model(
      List<LegBreakModel> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_leg_break_model(item, serializer);
    }
  }

  @protected
  void sse_encode_list_phase_model(
      List<PhaseModel> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_phase_model(item, serializer);
    }
  }

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint8List(self);
  }

  @protected
  void sse_encode_list_shield_change_model(
      List<ShieldChangeModel> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_shield_change_model(item, serializer);
    }
  }

  @protected
  void sse_encode_list_squad_member_model(
      List<SquadMemberModel> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_squad_member_model(item, serializer);
    }
  }

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_String(self, serializer);
    }
  }

  @protected
  void sse_encode_opt_box_autoadd_i_32(int? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_box_autoadd_i_32(self, serializer);
    }
  }

  @protected
  void sse_encode_phase_model(PhaseModel self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.phaseNumber, serializer);
    sse_encode_f_64(self.totalTime, serializer);
    sse_encode_f_64(self.totalShieldTime, serializer);
    sse_encode_f_64(self.totalLegTime, serializer);
    sse_encode_f_64(self.totalBodyKillTime, serializer);
    sse_encode_f_64(self.totalPylonTime, serializer);
    sse_encode_list_shield_change_model(self.shieldChanges, serializer);
    sse_encode_list_leg_break_model(self.legBreaks, serializer);
  }

  @protected
  void sse_encode_run_model(RunModel self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.runId, serializer);
    sse_encode_i_64(self.timeStamp, serializer);
    sse_encode_String(self.runName, serializer);
    sse_encode_String(self.playerName, serializer);
    sse_encode_bool(self.isBuggedRun, serializer);
    sse_encode_bool(self.isAbortedRun, serializer);
    sse_encode_bool(self.isSoloRun, serializer);
    sse_encode_total_times_model(self.totalTimes, serializer);
    sse_encode_list_phase_model(self.phases, serializer);
    sse_encode_list_squad_member_model(self.squadMembers, serializer);
  }

  @protected
  void sse_encode_shield_change_model(
      ShieldChangeModel self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_f_64(self.shieldTime, serializer);
    sse_encode_status_effect_enum(self.statusEffect, serializer);
  }

  @protected
  void sse_encode_squad_member_model(
      SquadMemberModel self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.memberName, serializer);
  }

  @protected
  void sse_encode_status_effect_enum(
      StatusEffectEnum self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.index, serializer);
  }

  @protected
  void sse_encode_total_times_model(
      TotalTimesModel self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_f_64(self.totalDuration, serializer);
    sse_encode_f_64(self.totalFlightTime, serializer);
    sse_encode_f_64(self.totalShieldTime, serializer);
    sse_encode_f_64(self.totalLegTime, serializer);
    sse_encode_f_64(self.totalBodyTime, serializer);
    sse_encode_f_64(self.totalPylonTime, serializer);
  }

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self);
  }

  @protected
  void sse_encode_unit(void self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }
}
