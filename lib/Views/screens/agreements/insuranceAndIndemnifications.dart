import 'package:flutter/material.dart';

import '../../../view_model/apiServices.dart';
import '../../widgets/cms_page_shell.dart';

class InsuranceAndIndemnification extends StatefulWidget {
  const InsuranceAndIndemnification({Key? key}) : super(key: key);

  @override
  State<InsuranceAndIndemnification> createState() =>
      _InsuranceAndIndemnificationState();
}

class _InsuranceAndIndemnificationState
    extends State<InsuranceAndIndemnification> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getInsurance() {
    ApiRepository.shared.insurance(
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
    getInsurance();
    super.initState();
  }

  String? _htmlBody() {
    final list = ApiRepository.shared.getInsuranceModelList?.data;
    if (list == null || list.isEmpty) return null;
    return list[0].description?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CmsPageShell(
      title: 'Insurance & Indemnifications Policy',
      body: CmsPageShell.htmlPolicyScroll(
        isLoading: isLoading,
        isError: isError,
        emptyData: emptyData,
        html: _htmlBody(),
      ),
    );
  }
}
