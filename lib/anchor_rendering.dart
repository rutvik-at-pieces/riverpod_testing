import 'dart:io';

import 'package:connector_openapi/api.dart';
import 'package:flutter/material.dart';
import 'package:pieces_core_connector/facades.dart';
import 'package:runtime_client/foundation.dart';

import 'main.dart';

class AnchorRendering {
  static Stream<LocalAnchorPointMetadata> streamAnchorPointMetadata({required LocalAnchorPoint point}) async* {
    if (point.metadata != null) {
      yield point.metadata ?? (throw Exception('AnchorPoint Metadata is null and not null at the same time'));
      return;
    }

    String path = point.path;
    LocalAnchorPointMetadata composed = LocalAnchorPointMetadata();

    if (!Directory(path).existsSync() && !File(path).existsSync()) {
      return;
    }

    bool directory = connectorApp.get<AnchorsFacade>().state.cache[point.anchor]?.type == AnchorTypeEnum.DIRECTORY;

    if (directory) {
      try {
        FileStat stats = await Directory(path).stat();
        yield LocalAnchorPointMetadata(lastModified: stats.modified);
        List<FileSystemEntity> files = Directory(path).listSync(recursive: true, followLinks: false);
        int size = 0;
        for (FileSystemEntity file in files) {
          size += (await file.stat()).size;
        }

        composed.size = size.readable;
        composed.lastModified = stats.modified;
        composed.count = files.length;

        yield composed;
      } catch (error) {
        debugPrint(error.toString());
      }
    } else {
      try {
        FileStat stats = await File(path).stat();

        composed.size = stats.size.readable;
        composed.lastModified = stats.modified;
        composed.count = 1;

        yield composed;

        /// Only if the file is less than 2MB will we try and read in the preview
        if (stats.size < 2000000) {
          String contents = await File(path).readAsString();
          composed.contents = contents;

          yield composed;

          TextSpan light = syntaxHighlight(
            text: contents,
            language: ConvertExtStringToClassificationSpecific.convert(
              ext: path.split('.').last,
            ),
            // codeThemeData: ParticleTheme.code,
          );

          composed.lightHighlight = light;
          yield composed;

          TextSpan dark = syntaxHighlight(
            text: contents,
            language: ConvertExtStringToClassificationSpecific.convert(
              ext: path.split('.').last,
            ),
            // theme: ParticleTheme.darkCode,
          );

          composed.darkHighlight = dark;
          yield composed;
        }
      } catch (error) {
        debugPrint(error.toString());
      }
    }

    /// !! KEY NOTE !!
    /// Only call update here as long as all of the actual data has loaded in. Otherwise we can
    /// run into an annoying situation where we are updating with an out-dated Anchor object
    if (point.metadata == null) {
      point = point.copyWith(metadata: composed);

      LocalAnchor? anchor = connectorApp.get<AnchorsFacade>().state.cache[point.anchor];

      anchor?.points.removeWhere((element) => element.pfd == point.pfd);
      anchor?.points.add(point);

      if (anchor == null) {
        debugPrint('Anchor not found in cache, cannot update metadata');
        return;
      }

      /// Update Anchor
      connectorApp.get<AnchorsFacade>().update(anchor);
    }
  }
}
