import 'package:flutter/material.dart';

import '../../../view_model/apiServices.dart';
import '../../widgets/cms_page_shell.dart';

class CopyrightPolicy extends StatefulWidget {
  const CopyrightPolicy({super.key});

  @override
  State<CopyrightPolicy> createState() => _CopyrightPolicyState();
}

class _CopyrightPolicyState extends State<CopyrightPolicy> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getTerm() {
    ApiRepository.shared.termLength(
      (List) {
        if (!mounted) return;
        if (List.status == 0) {
          setState(() {
            isLoading = false;
            emptyData = true;
            isError = false;
          });
        } else {
          setState(() {
            isLoading = false;
            emptyData = false;
            isError = false;
          });
        }
      },
      (error) {
        if (error != null && mounted) {
          setState(() {
            isLoading = false;
            isError = true;
            emptyData = false;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getTerm();
  }

  String? _htmlBody() {
    final list = ApiRepository.shared.getTermLengthModelList?.data;
    if (list == null || list.isEmpty) return null;
    return list[0].description?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CmsPageShell(
      title: 'Copyright Policy',
      body: CmsPageShell.htmlPolicyScroll(
        isLoading: isLoading,
        isError: isError,
        emptyData: emptyData,
        html: _htmlBody(),
      ),
    );
  }
}
