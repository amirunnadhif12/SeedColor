import '../../../editor/domain/entities/edit_parameters.dart';
import 'package:uuid/uuid.dart';

class XmpSerializer {
  static String serialize(EditParameters params, String presetName) {
    final uuid = const Uuid().v4();
    final buffer = StringBuffer();
    buffer.writeln('<x:xmpmeta xmlns:x="adobe:ns:meta/">');
    buffer.writeln(' <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">');
    buffer.writeln('  <rdf:Description rdf:about=""');
    buffer.writeln('    xmlns:crs="http://ns.adobe.com/camera-raw-settings/1.0/"');
    buffer.writeln('   crs:PresetType="Normal"');
    buffer.writeln('   crs:UUID="$uuid"');
    buffer.writeln('   crs:Name="$presetName"');
    buffer.writeln('   crs:Exposure2012="${params.exposure}"');
    buffer.writeln('   crs:Contrast2012="${params.contrast.round()}"');
    buffer.writeln('   crs:Highlights2012="${params.highlights.round()}"');
    buffer.writeln('   crs:Shadows2012="${params.shadows.round()}"');
    buffer.writeln('   crs:Whites2012="${params.whites.round()}"');
    buffer.writeln('   crs:Blacks2012="${params.blacks.round()}"');
    buffer.writeln('   crs:Temperature="${params.temperature.round()}"');
    buffer.writeln('   crs:Tint="${params.tint.round()}"');
    buffer.writeln('   crs:Vibrance="${params.vibrance.round()}"');
    buffer.writeln('   crs:Saturation="${params.saturation.round()}"');
    buffer.writeln('   crs:Texture="${params.texture.round()}"');
    buffer.writeln('   crs:Clarity="${params.clarity.round()}"');
    buffer.writeln('   crs:Dehaze="${params.dehaze.round()}"');
    buffer.writeln('   crs:VignetteAmount="${params.vignette.round()}"');
    buffer.writeln('   crs:GrainAmount="${params.grain.round()}"');
    buffer.writeln('   crs:Sharpness="${params.sharpeningAmount.round()}"');
    buffer.writeln('   crs:SharpenRadius="${params.sharpeningRadius}"');
    buffer.writeln('   crs:SharpenDetail="${params.sharpeningDetail.round()}"');
    buffer.writeln('   crs:SharpenEdgeMasking="${params.sharpeningMasking.round()}"');
    buffer.writeln('   crs:LuminanceSmoothing="${params.luminanceNR.round()}"');
    buffer.writeln('   crs:ColorNoiseReduction="${params.colorNR.round()}"');
    buffer.writeln('   crs:ChromaticAberration="${params.removeChromaticAberration ? 'True' : 'False'}"');
    buffer.writeln('   crs:LensProfileEnable="${params.enableLensCorrection ? 'True' : 'False'}"');
    buffer.writeln('  />');
    buffer.writeln(' </rdf:RDF>');
    buffer.writeln('</x:xmpmeta>');
    return buffer.toString();
  }

  static MapEntry<String, EditParameters> deserialize(String xmlString) {
    String name = 'Imported Preset';
    final nameMatch = RegExp(r'crs:Name="([^"]+)"').firstMatch(xmlString);
    if (nameMatch != null) {
      name = nameMatch.group(1)!;
    }

    double getDouble(String pattern, double defaultValue) {
      final match = RegExp(pattern).firstMatch(xmlString);
      if (match != null) {
        return double.tryParse(match.group(1)!) ?? defaultValue;
      }
      return defaultValue;
    }

    bool getBool(String pattern, bool defaultValue) {
      final match = RegExp(pattern).firstMatch(xmlString);
      if (match != null) {
        final val = match.group(1)!.toLowerCase();
        return val == 'true';
      }
      return defaultValue;
    }

    final exposure = getDouble(r'crs:Exposure2012="([^"]+)"', 0.0);
    final contrast = getDouble(r'crs:Contrast2012="([^"]+)"', 0.0);
    final highlights = getDouble(r'crs:Highlights2012="([^"]+)"', 0.0);
    final shadows = getDouble(r'crs:Shadows2012="([^"]+)"', 0.0);
    final whites = getDouble(r'crs:Whites2012="([^"]+)"', 0.0);
    final blacks = getDouble(r'crs:Blacks2012="([^"]+)"', 0.0);
    final temperature = getDouble(r'crs:Temperature="([^"]+)"', 0.0);
    final tint = getDouble(r'crs:Tint="([^"]+)"', 0.0);
    final vibrance = getDouble(r'crs:Vibrance="([^"]+)"', 0.0);
    final saturation = getDouble(r'crs:Saturation="([^"]+)"', 0.0);
    final texture = getDouble(r'crs:Texture="([^"]+)"', 0.0);
    final clarity = getDouble(r'crs:Clarity="([^"]+)"', 0.0);
    final dehaze = getDouble(r'crs:Dehaze="([^"]+)"', 0.0);
    final vignette = getDouble(r'crs:VignetteAmount="([^"]+)"', 0.0);
    final grain = getDouble(r'crs:GrainAmount="([^"]+)"', 0.0);
    final sharpness = getDouble(r'crs:Sharpness="([^"]+)"', 0.0);
    final sharpenRadius = getDouble(r'crs:SharpenRadius="([^"]+)"', 0.0);
    final sharpenDetail = getDouble(r'crs:SharpenDetail="([^"]+)"', 0.0);
    final sharpenMasking = getDouble(r'crs:SharpenEdgeMasking="([^"]+)"', 0.0);
    final luminanceNR = getDouble(r'crs:LuminanceSmoothing="([^"]+)"', 0.0);
    final colorNR = getDouble(r'crs:ColorNoiseReduction="([^"]+)"', 0.0);
    final chromaticAberration = getBool(r'crs:ChromaticAberration="([^"]+)"', false);
    final lensCorrection = getBool(r'crs:LensProfileEnable="([^"]+)"', false);

    final params = EditParameters.identity().copyWith(
      exposure: exposure,
      contrast: contrast,
      highlights: highlights,
      shadows: shadows,
      whites: whites,
      blacks: blacks,
      temperature: temperature,
      tint: tint,
      vibrance: vibrance,
      saturation: saturation,
      texture: texture,
      clarity: clarity,
      dehaze: dehaze,
      vignette: vignette,
      grain: grain,
      sharpeningAmount: sharpness,
      sharpeningRadius: sharpenRadius,
      sharpeningDetail: sharpenDetail,
      sharpeningMasking: sharpenMasking,
      luminanceNR: luminanceNR,
      colorNR: colorNR,
      removeChromaticAberration: chromaticAberration,
      enableLensCorrection: lensCorrection,
    );

    return MapEntry(name, params);
  }
}
