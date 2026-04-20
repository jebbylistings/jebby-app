import 'package:flutter/material.dart';

import 'package:jebby/view_model/apiServices.dart';

import '../../widgets/cms_page_shell.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getPrivPolicy() {
    ApiRepository.shared.privacyPolicy(
      (List) => {
        if (this.mounted)
          {
            if (List.status == 0)
              {
                setState(() {
                  isLoading = false;
                  emptyData = true;
                  isError = false;
                }),
              }
            else
              {
                setState(() {
                  isLoading = false;
                  emptyData = false;
                  isError = false;
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              isLoading = false;
              isError = true;
              emptyData = false;
            }),
          },
      },
    );
  }

  @override
  void initState() {
    getPrivPolicy();
    super.initState();
  }

  String? _htmlBody() {
    final list = ApiRepository.shared.getPrivacyPolicyModelList?.data;
    if (list == null || list.isEmpty) return null;
    return list[0].description?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CmsPageShell(
      title: 'Privacy Policy',
      body: CmsPageShell.htmlPolicyScroll(
        isLoading: isLoading,
        isError: isError,
        emptyData: emptyData,
        html: _htmlBody(),
        emptyMessage: 'Unable to load privacy policy. Please try again later.',
      ),
    );
  }
}
