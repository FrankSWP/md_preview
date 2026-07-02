import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/utils/markdown_parser.dart';

void main() {
  test('debug parseInlineSegments', () {
    final segs = parseInlineSegments('行内公式：\$E = mc^2\$');
    print('TEST1 segs.length: ${segs.length}');
    for (var i = 0; i < segs.length; i++) {
      print('[$i] ${segs[i].runtimeType}');
    }
    
    final segs2 = parseInlineSegments('[\$  E = mc^2  \$]');
    print('TEST2 segs.length: ${segs2.length}');
    for (var i = 0; i < segs2.length; i++) {
      print('[$i] ${segs2[i].runtimeType}');
    }
    
    final segs3 = parseInlineSegments('\$a\$ and \$b\$');
    print('TEST3 segs.length: ${segs3.length}');
    for (var i = 0; i < segs3.length; i++) {
      print('[$i] ${segs3[i].runtimeType}');
    }
  });
}
