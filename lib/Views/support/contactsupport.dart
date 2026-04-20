import 'package:flutter/material.dart';

import '../widgets/cms_page_shell.dart';

class ContactSupport extends StatefulWidget {
  const ContactSupport({Key? key}) : super(key: key);

  @override
  State<ContactSupport> createState() => _ContactSupportState();
}

class _ContactSupportState extends State<ContactSupport> {
  @override
  Widget build(BuildContext context) {
    return CmsPageShell(
      title: 'Contact Support',
      body: CmsPageShell.paddedScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Support', style: CmsPageShell.headingLarge()),
            const SizedBox(height: 12),
            Text(
              'At JEBBY, we are committed to providing you with the best rental experience possible. If you have any questions, concerns, or need assistance with our service, please don\'t hesitate to reach out to our dedicated support team. We\'re here to help you!',
              style: CmsPageShell.bodyParagraph(),
            ),
            CmsPageShell.sectionDivider(),
            Text('How to Contact Us', style: CmsPageShell.headingSection()),
            const SizedBox(height: 12),
            Text('1. In-App Support:', style: CmsPageShell.headingSection()),
            const SizedBox(height: 8),
            Text('• Open the JEBBY app.', style: CmsPageShell.bodyParagraph()),
            const SizedBox(height: 8),
            Text(
              '• Go to the top left bar to open the slider section.',
              style: CmsPageShell.bodyParagraph(),
            ),
            const SizedBox(height: 8),
            Text(
              '• Click on "Provide Feedback.',
              style: CmsPageShell.bodyParagraph(),
            ),
            const SizedBox(height: 8),
            Text(
              '• Follow the prompts to describe your issue or inquiry.',
              style: CmsPageShell.bodyParagraph(),
            ),
            const SizedBox(height: 8),
            Text(
              '• Our support team will respond to you as soon as possible via the app\'s messaging system or in your email.',
              style: CmsPageShell.bodyParagraph(),
            ),
            CmsPageShell.sectionDivider(),
            Text('2. Email Support:', style: CmsPageShell.headingSection()),
            const SizedBox(height: 8),
            Text(
              '• You can also reach us via email at [support@jebbylistings.com].',
              style: CmsPageShell.bodyParagraph(),
            ),
            const SizedBox(height: 8),
            Text(
              '• Please include your name, contact information, and a detailed description of your issue or question.',
              style: CmsPageShell.bodyParagraph(),
            ),
            const SizedBox(height: 8),
            Text(
              '• Our support team will respond to your email within [response time] during our business hours.',
              style: CmsPageShell.bodyParagraph(),
            ),
            CmsPageShell.sectionDivider(),
            Text(
              'Sincerely, The JEBBY Support Team',
              style: CmsPageShell.bodyParagraph(),
            ),
          ],
        ),
      ),
    );
  }
}
