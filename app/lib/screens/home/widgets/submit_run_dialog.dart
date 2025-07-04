import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:rust_core/rust_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';

// Extension to serialize RunModel for submission
extension RunModelSubmissionJson on RunModel {
  Map<String, dynamic> toSubmissionJson(
      {required String videoUrl, int? category}) {
    return {
      "time_stamp": timeStamp,
      "bugged_run": isBuggedRun,
      "aborted_run": isAbortedRun,
      "solo_run": isSoloRun,
      "total_time": totalTimes.totalDuration,
      "total_flight_time": totalTimes.totalFlightTime,
      "total_shield_time": totalTimes.totalShieldTime,
      "total_leg_time": totalTimes.totalLegTime,
      "total_body_time": totalTimes.totalBodyTime,
      "total_pylon_time": totalTimes.totalPylonTime,
      "video_url": videoUrl,
      "category": category,
      "squad_members": squadMembers
          .map((m) => {
                "member_name": m.memberName,
              })
          .toList(),
      "phases": phases
          .map((p) => {
                "phase_number": p.phaseNumber,
                "phase_time": p.totalTime,
                "shield_time": p.totalShieldTime,
                "leg_time": p.totalLegTime,
                "body_kill_time": p.totalBodyKillTime,
                "pylon_time": p.totalPylonTime,
              })
          .toList(),
      "shield_changes": phases
          .expand((p) => p.shieldChanges.map((s) => {
                "phase_number": p.phaseNumber,
                "shield_time": s.shieldTime,
                "shield_order": s.shieldOrder,
                "status_effect_id": s.statusEffect.index + 1,
              }))
          .toList(),
      "leg_breaks": phases
          .expand((p) => p.legBreaks.map((l) => {
                "phase_number": p.phaseNumber,
                "break_time": l.legBreakTime,
                "break_order": l.legOrder,
                "leg_position_id": l.legPosition.index + 1,
              }))
          .toList(),
    };
  }
}

class SubmitRunDialog extends StatefulWidget {
  const SubmitRunDialog({super.key});

  @override
  State<SubmitRunDialog> createState() => _SubmitRunDialogState();
}

class _SubmitRunDialogState extends State<SubmitRunDialog> {
  final TextEditingController _videoController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;
  int? _selectedCategory; // 1 = Volt, 2 = Chroma, null = None

  @override
  void initState() {
    super.initState();
    _selectedCategory = null; // Default to None
  }

  Future<void> _submitRun() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final videoUrl = _videoController.text.trim();
    if (videoUrl.isEmpty) {
      setState(() {
        _error = FlutterI18n.translate(context, "home.video_required");
        _isSubmitting = false;
      });
      return;
    }

    final run = context.read<RunNavigationService>().currentRun;
    final user = Supabase.instance.client.auth.currentUser;

    if (run == null || user == null) {
      setState(() {
        _error = "No run or user found.";
        _isSubmitting = false;
      });
      return;
    }

    final runJson =
        run.toSubmissionJson(videoUrl: videoUrl, category: _selectedCategory);

    try {
      final response = await Supabase.instance.client
          .rpc('submit_run_with_details', params: {
            'run_data': runJson,
            'user_id': user.id,
          })
          .select()
          .single();
      if (!mounted) return;
      if (response['success'] == true) {
        if (kDebugMode) {
          print('Run submission success:');
          print(response);
        }
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                FlutterI18n.translate(context, "home.submission_success"))));
      } else {
        if (kDebugMode) {
          print('Run submission error:');
          print(response['error']);
        }
        setState(() {
          // Custom error for duplicate runs
          if ((response['error'] ?? '')
              .toString()
              .toLowerCase()
              .contains('duplicate runs')) {
            _error = FlutterI18n.translate(context, "home.duplicate_run_error");
          } else {
            _error = response['error'] ?? 'Unknown error';
          }
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_error!)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Run submission error:');
        print(e);
      }
      setState(() {
        // Custom error for duplicate runs
        if (e.toString().toLowerCase().contains('duplicate runs')) {
          _error = FlutterI18n.translate(context, "home.duplicate_run_error");
        } else {
          _error = e.toString();
        }
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, "home.submit_run_title")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int?>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "home.category_label"),
            ),
            items: [
              DropdownMenuItem(
                  value: null,
                  child: Text(
                      FlutterI18n.translate(context, "home.category_none"))),
              DropdownMenuItem(value: 1, child: Text("Volt")),
              DropdownMenuItem(value: 2, child: Text("Chroma")),
            ],
            onChanged: _isSubmitting
                ? null
                : (val) => setState(() => _selectedCategory = val),
          ),
          TextField(
            controller: _videoController,
            decoration: InputDecoration(
              labelText:
                  FlutterI18n.translate(context, "home.video_proof_label"),
            ),
            keyboardType: TextInputType.url,
            enabled: !_isSubmitting,
          ),
          if (_error != null) ...[
            SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child:
              Text(FlutterI18n.translate(context, "settings.general.cancel")),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRun,
          child: _isSubmitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(FlutterI18n.translate(context, "home.submit")),
        ),
      ],
    );
  }
}
