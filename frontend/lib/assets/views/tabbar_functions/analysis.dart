import 'package:flutter/material.dart';

import 'package:frontend/assets/views/main/excel_upload.dart';

class Analysis extends StatelessWidget {
  const Analysis({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ExcelUpload(),
    );
  }
}
