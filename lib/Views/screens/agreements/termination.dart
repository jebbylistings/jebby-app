import 'package:flutter/material.dart';

import '../../../view_model/apiServices.dart';
import '../../widgets/cms_page_shell.dart';

class Termination extends StatefulWidget {
  const Termination({Key? key}) : super(key: key);

  @override
  State<Termination> createState() => _TerminationState();
}

class _TerminationState extends State<Termination> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getTermination() {
    ApiRepository.shared.termination(
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
    getTermination();
    super.initState();
  }

  String? _htmlBody() {
    final list = ApiRepository.shared.getTerminationModelList?.data;
    if (list == null || list.isEmpty) return null;
    return list[0].description?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CmsPageShell(
      title: 'Termination',
      body: CmsPageShell.htmlPolicyScroll(
        isLoading: isLoading,
        isError: isError,
        emptyData: emptyData,
        html: _htmlBody(),
      ),
    );
  }
}
