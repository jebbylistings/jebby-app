import 'package:flutter/material.dart';

import '../../../view_model/apiServices.dart';
import '../../widgets/cms_page_shell.dart';

class RentalAgreement extends StatefulWidget {
  const RentalAgreement({Key? key}) : super(key: key);

  @override
  State<RentalAgreement> createState() => _RentalAgreementState();
}

class _RentalAgreementState extends State<RentalAgreement> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getRental() {
    ApiRepository.shared.rentalAgreement(
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
    getRental();
    super.initState();
  }

  String? _htmlBody() {
    final list = ApiRepository.shared.getRentalAgreementModelList?.data;
    if (list == null || list.isEmpty) return null;
    return list[0].description?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CmsPageShell(
      title: 'Rental Agreement',
      body: CmsPageShell.htmlPolicyScroll(
        isLoading: isLoading,
        isError: isError,
        emptyData: emptyData,
        html: _htmlBody(),
      ),
    );
  }
}
