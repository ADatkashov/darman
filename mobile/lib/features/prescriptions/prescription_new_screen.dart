import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/file_kind.dart';
import '../../data/models/catalog_models.dart';
import '../../data/repositories/prescription_repository.dart';
import '../../design/form_fields.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n_ext.dart';
import '../../router/app_router.dart';
import '../../state/core_providers.dart';
import '../../state/data_providers.dart';
import '../../core/theme/colors.dart';

class _Picked {
  _Picked(this.name, this.bytes, this.kind);
  final String name;
  final Uint8List bytes;
  final FileKind kind;
}

class PrescriptionNewScreen extends ConsumerStatefulWidget {
  const PrescriptionNewScreen({super.key});
  @override
  ConsumerState<PrescriptionNewScreen> createState() => _PrescriptionNewScreenState();
}

class _PrescriptionNewScreenState extends ConsumerState<PrescriptionNewScreen> {
  final _picked = <_Picked>[];
  final _note = TextEditingController();
  final _imagePicker = ImagePicker();
  double? _progress;
  String? _error;
  String? _createdId; // draft already stored server-side; a retry only needs to submit it

  RuntimeConfig get _config => ref.read(runtimeConfigProvider).value ?? RuntimeConfig.fallback;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _add(String name, Uint8List bytes) async {
    final l = context.l10n;
    final cfg = _config;
    final kind = detectFileKind(bytes);
    String? problem;
    if (kind == null) {
      problem = l.rxBadType;
    } else if (bytes.length > cfg.maxPrescriptionFileBytes) {
      problem = l.rxTooLarge(cfg.maxPrescriptionFileBytes ~/ (1024 * 1024));
    } else if (_picked.length >= cfg.maxPrescriptionFiles) {
      problem = l.rxMaxFiles(cfg.maxPrescriptionFiles);
    }
    if (problem != null) {
      showSnack(context, problem);
      return;
    }
    setState(() {
      _picked.add(_Picked(name, bytes, kind!));
      _error = null;
    });
  }

  Future<void> _camera() async {
    try {
      final x = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 88, maxWidth: 2400);
      if (x != null) await _add(x.name, await x.readAsBytes());
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.errUnknown);
    }
  }

  Future<void> _gallery() async {
    try {
      final xs = await _imagePicker.pickMultiImage(imageQuality: 88, maxWidth: 2400);
      for (final x in xs) {
        if (!mounted) return;
        await _add(x.name, await x.readAsBytes());
      }
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.errUnknown);
    }
  }

  Future<void> _pdf() async {
    try {
      final f = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['pdf']);
      if (f != null) await _add(f.name, await f.xFile.readAsBytes());
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.errUnknown);
    }
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (_picked.isEmpty && _createdId == null) {
      setState(() => _error = l.rxNoFiles);
      return;
    }
    setState(() {
      _error = null;
      _progress = 0;
    });
    final repo = ref.read(prescriptionRepositoryProvider);
    try {
      if (_createdId == null) {
        final created = await repo.create(
          [for (final p in _picked) UploadFile(name: p.name.contains('.') ? p.name : '${p.name}.${extensionFor(p.kind)}', bytes: p.bytes)],
          note: _note.text,
          onProgress: (v) {
            if (mounted) setState(() => _progress = v);
          },
        );
        _createdId = created.id;
      }
      final submitted = await repo.submit(_createdId!);
      ref.invalidate(prescriptionsProvider);
      if (!mounted) return;
      showSnack(context, l.rxSubmittedOk);
      context.pushReplacement(Routes.prescription(submitted.id));
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = errorText(l, e));
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cfg = _config;
    final busy = _progress != null;
    return Scaffold(
      appBar: AppBar(title: Text(l.rxUploadTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(Sp.gutter, Sp.x2, Sp.gutter, MediaQuery.viewInsetsOf(context).bottom + Sp.x8),
        children: [
          InfoPanel(icon: Icons.verified_user_outlined, text: l.rxLegal),
          const SizedBox(height: Sp.x4),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Sp.x4),
              child: InlineError(_error!),
            ),
          DmCard(
            color: context.dm.paleAqua,
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 44, color: context.scheme.primary),
                const SizedBox(height: Sp.x2),
                Text(
                  l.rxUploadHint(cfg.maxPrescriptionFileBytes ~/ (1024 * 1024)),
                  style: context.text.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sp.x4),
                Wrap(
                  spacing: Sp.x2,
                  runSpacing: Sp.x2,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: busy || _createdId != null ? null : _camera,
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(l.rxTakePhoto),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy || _createdId != null ? null : _gallery,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l.rxGallery),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy || _createdId != null ? null : _pdf,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(l.rxPdf),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.x4),
          if (_picked.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: Sp.x2,
                mainAxisSpacing: Sp.x2,
              ),
              itemCount: _picked.length,
              itemBuilder: (_, i) {
                final p = _picked[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: p.kind == FileKind.pdf
                          ? Container(
                              color: context.dm.softMint,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.picture_as_pdf_outlined, size: 36, color: context.scheme.primary),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      p.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: context.text.labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Image.memory(p.bytes, fit: BoxFit.cover, semanticLabel: p.name),
                    ),
                    if (_createdId == null)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: busy ? null : () => setState(() => _picked.removeAt(i)),
                            child: Tooltip(
                              message: l.rxFileRemove,
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: Sp.x4),
          TextField(
            controller: _note,
            maxLength: 300,
            maxLines: 2,
            enabled: _createdId == null && !busy,
            decoration: InputDecoration(labelText: l.rxNote),
          ),
          const SizedBox(height: Sp.x4),
          if (busy) ...[
            LinearProgressIndicator(value: (_progress ?? 0) >= 1 ? null : _progress, minHeight: 6, borderRadius: BorderRadius.circular(3)),
            const SizedBox(height: Sp.x2),
            Text(l.rxUploading(((_progress ?? 0) * 100).round()), style: context.text.bodySmall),
            const SizedBox(height: Sp.x4),
          ],
          FilledButton(onPressed: busy ? null : _submit, child: Text(l.rxSubmit)),
        ],
      ),
    );
  }
}
