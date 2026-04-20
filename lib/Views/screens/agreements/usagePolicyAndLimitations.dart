import 'package:flutter/material.dart';

import 'package:jebby/view_model/apiServices.dart';

import '../../widgets/cms_page_shell.dart';

class usagePolicyAndLimitations extends StatefulWidget {
  const usagePolicyAndLimitations({Key? key}) : super(key: key);

  @override
  State<usagePolicyAndLimitations> createState() =>
      _usagePolicyAndLimitationsState();
}

class _usagePolicyAndLimitationsState extends State<usagePolicyAndLimitations> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getUsage() {
    ApiRepository.shared.usagePolicy(
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
    getUsage();
    super.initState();
  }

  String? _htmlBody() {
    final list = ApiRepository.shared.getUsagePolicyModelList?.data;
    if (list == null || list.isEmpty) return null;
    return list[0].description?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CmsPageShell(
      title: 'Usage Policy & Limitations',
      body: CmsPageShell.htmlPolicyScroll(
        isLoading: isLoading,
        isError: isError,
        emptyData: emptyData,
        html: _htmlBody(),
      ),
    );
  }
}
